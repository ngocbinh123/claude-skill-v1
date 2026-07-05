#!/usr/bin/env node
// Behavioral eval runner ("JUnit for skills").
//
// For every scenario in evals/<plugin>/<skill>/scenarios.md it runs a
// headless `claude -p` in advice mode (all tools disabled, single response):
//   - with-skill arm: SKILL.md injected as a triggered skill
//   - baseline arm (--ablation): plain Claude, to prove the skill changes
//     behavior (RED evidence)
// An LLM judge grades the response against the scenario's expected-behavior
// checklist. Results go to the console, a JSON file, and JUnit XML so CI
// can treat expected behaviors as test cases.
//
// Usage:
//   node tools/run-evals.js --dry-run                 # list parsed cases, no API calls
//   node tools/run-evals.js --plugin bi-git           # one plugin
//   node tools/run-evals.js --plugin bi-git --skill bi-pr-workflow --scenario S2
//   node tools/run-evals.js --ablation                # also run no-skill baseline
//   node tools/run-evals.js --model sonnet --judge-model haiku
//
// Exit codes: 0 all with-skill items pass; 1 any failure; 2 setup error.

const fs = require('fs');
const path = require('path');
const { spawnSync } = require('child_process');

const ROOT = path.join(__dirname, '..');
const EVALS_DIR = path.join(ROOT, 'evals');
const RESULTS_DIR = path.join(EVALS_DIR, 'results');

const args = process.argv.slice(2);
const opt = (name, fallback) => {
  const i = args.indexOf(`--${name}`);
  return i >= 0 && args[i + 1] && !args[i + 1].startsWith('--') ? args[i + 1] : fallback;
};
const has = (name) => args.includes(`--${name}`);

const FILTER_PLUGIN = opt('plugin');
const FILTER_SKILL = opt('skill');
const FILTER_SCENARIO = opt('scenario');
const MODEL = opt('model', 'sonnet');
const JUDGE_MODEL = opt('judge-model', 'haiku');
const ABLATION = has('ablation');
const DRY_RUN = has('dry-run');
const TIMEOUT_MS = Number(opt('timeout', '300')) * 1000;

// ---------- parse scenarios.md ----------

function parseScenarios(file) {
  const raw = fs.readFileSync(file, 'utf8');
  const scenarios = [];
  const sections = raw.split(/^## /m).slice(1);
  for (const section of sections) {
    const header = section.split('\n')[0].trim(); // "S1: Mixed-intent working tree"
    const id = (header.match(/^(S\d+)/) || [])[1];
    if (!id) continue;
    const promptMatch = section.match(/\*\*Prompt:\*\*\s*([\s\S]*?)\n\s*\n/);
    if (!promptMatch) continue;
    const prompt = promptMatch[1].replace(/\s+/g, ' ').trim();
    const expected = [];
    const lines = section.split('\n');
    for (let i = 0; i < lines.length; i++) {
      const m = lines[i].match(/^- \[ \] (.*)$/);
      if (!m) continue;
      let item = m[1];
      while (i + 1 < lines.length && /^ {2,}\S/.test(lines[i + 1]) && !/^\s*- \[ \]/.test(lines[i + 1])) {
        item += ' ' + lines[++i].trim();
      }
      expected.push(item.trim());
    }
    if (expected.length) scenarios.push({ id, title: header.replace(/^S\d+:\s*/, ''), prompt, expected });
  }
  return scenarios;
}

function collectCases() {
  const cases = [];
  for (const plugin of fs.readdirSync(EVALS_DIR)) {
    if (plugin === 'results' || !fs.statSync(path.join(EVALS_DIR, plugin)).isDirectory()) continue;
    if (FILTER_PLUGIN && plugin !== FILTER_PLUGIN) continue;
    for (const skill of fs.readdirSync(path.join(EVALS_DIR, plugin))) {
      const spec = path.join(EVALS_DIR, plugin, skill, 'scenarios.md');
      if (!fs.existsSync(spec)) continue;
      if (FILTER_SKILL && skill !== FILTER_SKILL) continue;
      const skillMd = path.join(ROOT, 'plugins', plugin, 'skills', skill, 'SKILL.md');
      if (!fs.existsSync(skillMd)) {
        console.error(`WARN: skipping ${plugin}/${skill} — no SKILL.md`);
        continue;
      }
      for (const scenario of parseScenarios(spec)) {
        if (FILTER_SCENARIO && scenario.id !== FILTER_SCENARIO) continue;
        cases.push({ plugin, skill, skillMd, ...scenario });
      }
    }
  }
  return cases;
}

// ---------- claude invocations ----------

function runClaude(promptText, model, systemAppend) {
  const cliArgs = ['-p', promptText, '--model', model, '--tools', ''];
  if (systemAppend) cliArgs.push('--append-system-prompt', systemAppend);
  const res = spawnSync('claude', cliArgs, { encoding: 'utf8', timeout: TIMEOUT_MS });
  if (res.error) throw new Error(`claude CLI failed: ${res.error.message}`);
  if (res.status !== 0) throw new Error(`claude exited ${res.status}: ${(res.stderr || '').slice(0, 400)}`);
  return (res.stdout || '').trim();
}

function skillSystemPrompt(caseDef) {
  const body = fs.readFileSync(caseDef.skillMd, 'utf8').replace(/^---[\s\S]*?---\n/, '');
  return (
    `A skill named "${caseDef.skill}" is installed and has been triggered for this request. ` +
    `Follow its instructions exactly. You cannot execute tools in this session, so state ` +
    `concretely what you would do and in what order.\n\n--- SKILL ---\n${body}`
  );
}

function judge(caseDef, response) {
  const checklist = caseDef.expected.map((e, i) => `${i + 1}. ${e}`).join('\n');
  const judgePrompt =
    `You are grading an AI coding assistant's response. The assistant answered in advice mode ` +
    `(no tool execution), so grade the APPROACH it commits to, not literal execution.\n\n` +
    `User request:\n${caseDef.prompt}\n\n` +
    `Assistant response:\n"""\n${response}\n"""\n\n` +
    `Expected behaviors:\n${checklist}\n\n` +
    `For each numbered item, decide pass or fail with a short evidence quote or reason. ` +
    `Be strict: vague gestures toward an item do not pass. ` +
    `Respond with ONLY this JSON, no other text:\n` +
    `{"results":[{"item":1,"pass":true,"reason":"..."}, ...]}`;
  const out = runClaude(judgePrompt, JUDGE_MODEL);
  const jsonText = out.slice(out.indexOf('{'), out.lastIndexOf('}') + 1);
  const parsed = JSON.parse(jsonText);
  if (!Array.isArray(parsed.results) || parsed.results.length !== caseDef.expected.length) {
    throw new Error(`judge returned ${parsed.results?.length ?? 0} results, expected ${caseDef.expected.length}`);
  }
  return parsed.results;
}

// ---------- reporting ----------

const xmlEscape = (s) => String(s).replace(/[<>&"']/g, (c) => ({ '<': '&lt;', '>': '&gt;', '&': '&amp;', '"': '&quot;', "'": '&apos;' }[c]));

function writeJUnit(allResults, file) {
  const suites = [];
  const bySkill = {};
  for (const r of allResults) (bySkill[`${r.plugin}/${r.skill}`] ||= []).push(r);
  for (const [suite, rows] of Object.entries(bySkill)) {
    const cases = [];
    let failures = 0;
    for (const row of rows) {
      for (const item of row.items) {
        const name = `${row.scenario} [${row.arm}] ${item.text}`;
        if (item.pass) {
          cases.push(`    <testcase classname="${xmlEscape(suite)}" name="${xmlEscape(name)}"/>`);
        } else {
          failures++;
          cases.push(
            `    <testcase classname="${xmlEscape(suite)}" name="${xmlEscape(name)}">\n` +
            `      <failure message="${xmlEscape(item.reason || 'behavior not observed')}"/>\n` +
            `    </testcase>`
          );
        }
      }
    }
    suites.push(
      `  <testsuite name="${xmlEscape(suite)}" tests="${rows.reduce((n, r) => n + r.items.length, 0)}" failures="${failures}">\n` +
      cases.join('\n') + '\n  </testsuite>'
    );
  }
  fs.writeFileSync(file, `<?xml version="1.0" encoding="UTF-8"?>\n<testsuites>\n${suites.join('\n')}\n</testsuites>\n`);
}

// ---------- main ----------

const cases = collectCases();
if (!cases.length) {
  console.error('No eval cases matched the filters.');
  process.exit(2);
}

console.log(`${cases.length} scenario(s) matched` + (DRY_RUN ? ' (dry run)' : ` — model=${MODEL}, judge=${JUDGE_MODEL}, ablation=${ABLATION}`));
if (DRY_RUN) {
  for (const c of cases) console.log(`  ${c.plugin}/${c.skill} ${c.id}: ${c.title} (${c.expected.length} expected behaviors)`);
  process.exit(0);
}

const stamp = new Date().toISOString().replace(/[:.]/g, '-');
const outDir = path.join(RESULTS_DIR, stamp);
fs.mkdirSync(outDir, { recursive: true });

const allResults = [];
let hardFail = false;

for (const c of cases) {
  const arms = ABLATION ? ['baseline', 'with-skill'] : ['with-skill'];
  for (const arm of arms) {
    process.stdout.write(`${c.plugin}/${c.skill} ${c.id} [${arm}] ... `);
    try {
      const response = runClaude(c.prompt, MODEL, arm === 'with-skill' ? skillSystemPrompt(c) : undefined);
      const verdicts = judge(c, response);
      const items = verdicts.map((v, i) => ({ text: c.expected[i], pass: !!v.pass, reason: v.reason || '' }));
      const passed = items.filter((i) => i.pass).length;
      allResults.push({ plugin: c.plugin, skill: c.skill, scenario: c.id, arm, items, response });
      console.log(`${passed}/${items.length} pass`);
      if (arm === 'with-skill' && passed < items.length) {
        hardFail = true;
        for (const i of items.filter((x) => !x.pass)) console.log(`    FAIL: ${i.text}\n          ${i.reason}`);
      }
      if (arm === 'baseline' && passed === items.length) {
        console.log(`    WARN: baseline already passes everything — scenario may be too easy (${c.id})`);
      }
    } catch (err) {
      hardFail = true;
      allResults.push({ plugin: c.plugin, skill: c.skill, scenario: c.id, arm, items: c.expected.map((text) => ({ text, pass: false, reason: `run error: ${err.message}` })) });
      console.log(`ERROR: ${err.message}`);
    }
  }
}

fs.writeFileSync(path.join(outDir, 'results.json'), JSON.stringify(allResults, null, 2));
writeJUnit(allResults, path.join(outDir, 'junit.xml'));
writeJUnit(allResults, path.join(RESULTS_DIR, 'junit.xml')); // stable path for CI
console.log(`\nResults: ${path.relative(ROOT, outDir)}/ (results.json, junit.xml)`);
process.exit(hardFail ? 1 : 0);
