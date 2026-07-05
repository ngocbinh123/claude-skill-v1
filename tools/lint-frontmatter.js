#!/usr/bin/env node
// Lints every plugins/*/skills/*/SKILL.md against repo authoring rules
// (see docs/authoring.md):
//   - frontmatter has exactly `name` and `description`
//   - name is kebab-case and matches the skill directory name
//   - description contains a "Use when" trigger phrase
//   - body is at most 500 lines (progressive disclosure: push depth to references/)

const fs = require('fs');
const path = require('path');

const ROOT = path.join(__dirname, '..');
const PLUGINS_DIR = path.join(ROOT, 'plugins');
const MAX_BODY_LINES = 500;

const errors = [];
let count = 0;

for (const plugin of fs.readdirSync(PLUGINS_DIR)) {
  const skillsDir = path.join(PLUGINS_DIR, plugin, 'skills');
  if (!fs.existsSync(skillsDir)) continue;
  for (const skill of fs.readdirSync(skillsDir)) {
    const skillMd = path.join(skillsDir, skill, 'SKILL.md');
    const rel = path.relative(ROOT, skillMd);
    if (!fs.existsSync(skillMd)) {
      errors.push(`${rel}: missing SKILL.md`);
      continue;
    }
    count++;
    const raw = fs.readFileSync(skillMd, 'utf8');
    const match = raw.match(/^---\n([\s\S]*?)\n---\n?([\s\S]*)$/);
    if (!match) {
      errors.push(`${rel}: missing YAML frontmatter block`);
      continue;
    }
    const [, frontmatter, body] = match;
    const fields = {};
    for (const line of frontmatter.split('\n')) {
      const m = line.match(/^([a-zA-Z-]+):\s*(.*)$/);
      if (m) fields[m[1]] = m[2].trim();
    }
    if (!fields.name) {
      errors.push(`${rel}: frontmatter missing "name"`);
    } else {
      if (!/^[a-z0-9]+(-[a-z0-9]+)*$/.test(fields.name)) {
        errors.push(`${rel}: name "${fields.name}" is not kebab-case`);
      }
      if (fields.name !== skill) {
        errors.push(`${rel}: name "${fields.name}" does not match directory "${skill}"`);
      }
    }
    if (!fields.description) {
      errors.push(`${rel}: frontmatter missing "description"`);
    } else {
      if (!/use (proactively )?when/i.test(fields.description)) {
        errors.push(`${rel}: description missing a "Use when ..." trigger phrase`);
      }
      if (fields.description.length > 1024) {
        errors.push(`${rel}: description longer than 1024 characters`);
      }
    }
    const bodyLines = body.split('\n').length;
    if (bodyLines > MAX_BODY_LINES) {
      errors.push(`${rel}: body has ${bodyLines} lines (max ${MAX_BODY_LINES}); move depth to references/`);
    }
  }
}

if (errors.length) {
  console.error(errors.map((e) => `ERROR: ${e}`).join('\n'));
  process.exit(1);
}
console.log(`OK: ${count} skills pass frontmatter lint`);
