# Skill Authoring Guide

The single style guide for every skill in this repo. `tools/lint-frontmatter.js`
enforces the mechanical parts; the rest is enforced in review.

## Frontmatter

Exactly two fields — extra fields hurt portability across agent harnesses:

```yaml
---
name: bi-rn-performance
description: Diagnose and fix React Native performance problems - slow lists, dropped frames, re-render storms. Use when a React Native app is slow, laggy, janky, or has low FPS.
---
```

- `name`: kebab-case, must equal the directory name.
- `description`: third person; states WHAT the skill does AND a
  "Use when ..." trigger phrase listing the concrete words users say
  (error messages, symptoms, tool names). The description is the ONLY thing
  Claude sees before deciding to load the skill — put every trigger keyword
  here, not in the body.

## Body structure

```markdown
# Title

## Overview            ← core principle in 2-4 lines, the one thing to remember
## <workflow sections> ← numbered steps, tables for signature→fix matrices
## Verification        ← how the agent proves the fix worked (if applicable)
## Anti-patterns       ← "Do NOT ..." list closing rationalization loopholes
```

Rules:

- Body ≤ 500 lines (lint-enforced); target 60–200. SKILL.md is a dispatcher.
- Depth goes to `references/<topic>.md` (one level deep, linked from the
  body). Executables go to `scripts/`. Reusable templates go to `assets/`.
- Be opinionated: give ONE default path plus an escape hatch, never a menu
  of equal options.
- Concrete over abstract: real commands, real error strings, real numbers.
- No time-sensitive phrasing ("as of 2026", "the new X"); write "old
  pattern / current pattern" tables instead.
- Forward slashes in all paths. English content.

## TDD workflow (required for every new skill)

See `evals/README.md`. In short: write `evals/<plugin>/<skill>/scenarios.md`
FIRST, record the no-skill baseline (RED), write the skill until scenarios
pass in a fresh session (GREEN), then close loopholes (REFACTOR). A skill PR
without scenarios is incomplete.

## Adding a new skill — checklist

- [ ] `evals/<plugin>/<skill>/scenarios.md` written first, baseline recorded
- [ ] `plugins/<plugin>/skills/<skill>/SKILL.md` passes `node tools/lint-frontmatter.js`
- [ ] Description contains every trigger keyword a user would actually type
- [ ] Anti-patterns section exists
- [ ] Scenarios pass with the skill installed (GREEN evidence in baseline.md)
- [ ] Plugin `version` bumped (minor for new skill) + `node tools/sync-versions.js`
- [ ] Plugin `CHANGELOG.md` updated

## Adding a new plugin — checklist

- [ ] `plugins/<name>/.claude-plugin/plugin.json` (copy shape from bi-git)
- [ ] Per-plugin `README.md`, `LICENSE`, `CHANGELOG.md`
- [ ] At least one skill following the skill checklist
- [ ] Entry added to `.claude-plugin/marketplace.json`, then `node tools/sync-versions.js`
- [ ] CI green (`validate.yml` runs the same `claude plugin validate` Anthropic uses)
