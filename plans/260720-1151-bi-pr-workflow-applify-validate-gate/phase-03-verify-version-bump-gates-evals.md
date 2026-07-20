---
phase: 3
title: Verify - version bump + gates + evals
status: completed
effort: S
dependencies:
  - 2
---

# Phase 3: Verify - version bump + gates + evals

## Overview

Release hygiene: bump plugin version, sync marketplace, run static gates and
the behavioral eval runner.

## Requirements

- Functional: version reflects a feature-level change (minor bump).
- Non-functional: versions edited ONLY in plugin.json; marketplace.json synced
  by tool, never by hand (architecture layer rule).

## Related Code Files

- Modify: `plugins/bi-git/.claude-plugin/plugin.json` (0.1.2 → 0.2.0)
- Modify (generated): `.claude-plugin/marketplace.json` via sync tool
- Modify: `plugins/bi-git/CHANGELOG.md` (entry for 0.2.0)

## Implementation Steps

1. Edit `plugins/bi-git/.claude-plugin/plugin.json`: `"version": "0.2.0"`.
2. Run `node tools/sync-versions.js` to propagate to marketplace.json.
3. Add CHANGELOG entry: validate gate + Applify PR template for bi-pr-workflow.
4. Static gates:
   `node tools/lint-frontmatter.js && node tools/check-governance.js && node tools/sync-versions.js --check`
   — all must exit 0.
5. Behavioral gate (needs ANTHROPIC_API_KEY):
   `node tools/run-evals.js --plugin bi-git --skill bi-pr-workflow`
   — S1–S9 pass; use `--ablation` on S4/S6/S8 to confirm RED arm still fails
   without the skill (scenario sharpness).
6. If eval API access unavailable: run `--dry-run` for parse check, grade S4–S9
   manually per evals/README.md, and record the limitation in the final report.

## Success Criteria

- [ ] plugin.json = 0.2.0; marketplace.json synced by tool
- [ ] All three static gates pass
- [ ] Eval runner (or documented manual grading) shows S1–S9 pass
- [ ] CHANGELOG updated

## Risk Assessment

- Eval flakiness: per evals/README.md the runner re-samples a failing
  with-skill scenario once by default (a `--retries` flag is documented but
  not confirmed in run-evals.js source); a persistent fail = real behavior
  gap → back to phase 2, not threshold tweaking.
  <!-- Updated: Validation Session 1 - softened unverified flag claim -->
- Do not merge to master until all gates green (master = stable release
  channel tracked by community marketplace).
