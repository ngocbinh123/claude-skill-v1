#!/usr/bin/env node
// Mechanical governance rules (docs/governance.md), run on every PR:
//   1. Every skill has eval scenarios (TDD rule: no skill without a spec)
//   2. Scenario files contain at least one prompt and one expected behavior
//   3. Every plugin ships README.md, LICENSE, CHANGELOG.md
//   4. Plugin dirs and skill dirs use the bi- brand prefix

const fs = require('fs');
const path = require('path');

const ROOT = path.join(__dirname, '..');
const PLUGINS_DIR = path.join(ROOT, 'plugins');
const EVALS_DIR = path.join(ROOT, 'evals');

const errors = [];

for (const plugin of fs.readdirSync(PLUGINS_DIR)) {
  const pluginDir = path.join(PLUGINS_DIR, plugin);
  if (!fs.statSync(pluginDir).isDirectory()) continue;

  const isPackaged = fs.existsSync(path.join(pluginDir, '.claude-plugin', 'plugin.json'));
  if (!plugin.startsWith('bi-')) {
    errors.push(`plugins/${plugin}: plugin directory missing bi- prefix`);
  }
  if (!isPackaged) continue; // placeholder dirs only need the prefix rule

  for (const file of ['README.md', 'LICENSE', 'CHANGELOG.md']) {
    if (!fs.existsSync(path.join(pluginDir, file))) {
      errors.push(`plugins/${plugin}: missing ${file}`);
    }
  }

  const skillsDir = path.join(pluginDir, 'skills');
  if (!fs.existsSync(skillsDir)) continue;
  for (const skill of fs.readdirSync(skillsDir)) {
    if (!skill.startsWith('bi-')) {
      errors.push(`plugins/${plugin}/skills/${skill}: skill directory missing bi- prefix`);
    }
    const scenarios = path.join(EVALS_DIR, plugin, skill, 'scenarios.md');
    if (!fs.existsSync(scenarios)) {
      errors.push(`plugins/${plugin}/skills/${skill}: no eval spec at evals/${plugin}/${skill}/scenarios.md (TDD rule)`);
      continue;
    }
    const raw = fs.readFileSync(scenarios, 'utf8');
    if (!/\*\*Prompt:\*\*/.test(raw)) {
      errors.push(`evals/${plugin}/${skill}/scenarios.md: no "**Prompt:**" found`);
    }
    if (!/^- \[ \] /m.test(raw)) {
      errors.push(`evals/${plugin}/${skill}/scenarios.md: no "- [ ]" expected-behavior items found`);
    }
  }
}

// Every eval spec must point at a real skill (catch renames that orphan specs)
if (fs.existsSync(EVALS_DIR)) {
  for (const plugin of fs.readdirSync(EVALS_DIR)) {
    const dir = path.join(EVALS_DIR, plugin);
    if (!fs.statSync(dir).isDirectory() || plugin === 'results') continue;
    for (const skill of fs.readdirSync(dir)) {
      if (!fs.statSync(path.join(dir, skill)).isDirectory()) continue;
      if (!fs.existsSync(path.join(PLUGINS_DIR, plugin, 'skills', skill, 'SKILL.md'))) {
        errors.push(`evals/${plugin}/${skill}: orphan eval spec — no matching skill directory`);
      }
    }
  }
}

if (errors.length) {
  console.error(errors.map((e) => `ERROR: ${e}`).join('\n'));
  process.exit(1);
}
console.log('OK: governance rules pass');
