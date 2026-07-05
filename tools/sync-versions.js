#!/usr/bin/env node
// Single source of truth for plugin versions is each plugin's
// .claude-plugin/plugin.json. This script propagates those versions into
// .claude-plugin/marketplace.json so the two can never drift.
//
//   node tools/sync-versions.js          # rewrite marketplace.json from plugin manifests
//   node tools/sync-versions.js --check  # exit 1 if marketplace.json is out of sync (CI)

const fs = require('fs');
const path = require('path');

const ROOT = path.join(__dirname, '..');
const MARKETPLACE = path.join(ROOT, '.claude-plugin', 'marketplace.json');
const PLUGINS_DIR = path.join(ROOT, 'plugins');

const checkMode = process.argv.includes('--check');

const marketplace = JSON.parse(fs.readFileSync(MARKETPLACE, 'utf8'));
const errors = [];
let changed = false;

for (const entry of marketplace.plugins) {
  if (typeof entry.source !== 'string' || !entry.source.startsWith('./plugins/')) {
    continue; // external SHA-pinned entries are not managed by this script
  }
  const manifestPath = path.join(ROOT, entry.source, '.claude-plugin', 'plugin.json');
  if (!fs.existsSync(manifestPath)) {
    errors.push(`${entry.name}: missing manifest at ${manifestPath}`);
    continue;
  }
  const manifest = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));
  if (manifest.name !== entry.name) {
    errors.push(`${entry.name}: plugin.json name is "${manifest.name}" (must match marketplace entry)`);
  }
  if (manifest.version !== entry.version) {
    if (checkMode) {
      errors.push(`${entry.name}: version drift — plugin.json=${manifest.version}, marketplace.json=${entry.version}`);
    } else {
      entry.version = manifest.version;
      changed = true;
      console.log(`synced ${entry.name} -> ${manifest.version}`);
    }
  }
}

// Every plugin directory must be listed in the marketplace.
const listed = new Set(marketplace.plugins.map((p) => p.name));
for (const dir of fs.readdirSync(PLUGINS_DIR)) {
  const manifestPath = path.join(PLUGINS_DIR, dir, '.claude-plugin', 'plugin.json');
  if (fs.existsSync(manifestPath) && !listed.has(dir)) {
    errors.push(`plugins/${dir} exists but has no marketplace.json entry`);
  }
}

if (errors.length) {
  console.error(errors.map((e) => `ERROR: ${e}`).join('\n'));
  process.exit(1);
}
if (changed) {
  fs.writeFileSync(MARKETPLACE, JSON.stringify(marketplace, null, 2) + '\n');
  console.log('marketplace.json updated');
} else {
  console.log('marketplace.json is in sync');
}
