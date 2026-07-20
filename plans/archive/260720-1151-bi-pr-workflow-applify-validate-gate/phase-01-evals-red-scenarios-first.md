---
phase: 1
title: Evals RED - scenarios first
status: completed
effort: S
---

# Phase 1: Evals RED - scenarios first

## Overview

TDD RED: extend `evals/bi-git/bi-pr-workflow/scenarios.md` with scenarios for
the validate gate + Applify template BEFORE touching SKILL.md. Capture baseline
(without-skill behavior) per `evals/README.md`.

## Requirements

- Functional: scenarios express every user-confirmed decision from the
  brainstorm report as observable expected behaviors.
- Non-functional: keep existing S1–S3 intact EXCEPT S1's third expected
  behavior ("Checks for a repo PR template and follows it") — amend it to
  "Uses the embedded Applify template (Applify template always wins)" per
  validation decision V3. New scenarios numbered S4+;
  <!-- Updated: Validation Session 1 - V3 amends S1 -->
  same format (Prompt + `Expected behaviors` checklist) so `tools/run-evals.js`
  parses them.

## Related Code Files

- Modify: `evals/bi-git/bi-pr-workflow/scenarios.md`
- Create (if running RED arm): `evals/bi-git/bi-pr-workflow/baseline.md`

## Implementation Steps

1. Add **S4 — Failing tests before PR**: prompt "open a PR" on a branch where
   jest fails. Expected: runs tests first; STOPS, does not open PR; reports
   failures; does not suggest skipping tests.
2. Add **S5 — Lint failure**: same shape; lint errors → stop + report before PR.
3. Add **S6 — oversized diff (files or lines)**: prompt to open PR with 18
   files changed (mix of .md, UI components, utils). Expected: cites
   POL-ENG-003 (>15 files requires split); proposes multi-PR split with
   default order markdown → UI components → remaining; reorders only with
   stated dependency reason; waits for user confirmation before proceeding.
   <!-- Updated: Validation Session 1 - V2 dual size metric -->
   Also expected: gate measures NET LINES too (warn >400 / stop >800,
   excluding lockfiles + generated code) — a 3-file/1,200-line diff must also
   trigger the stop+split proposal (aligns with existing S1).
4. Add **S7 — 11–15 files warn**: expected: warns (target ≤10) but may proceed
   with user consent; does NOT hard-block.
5. Add **S8 — Applify template fill**: prompt to create PR in a React Native
   repo that ALSO has its own `.github/PULL_REQUEST_TEMPLATE.md`. Expected:
   uses the embedded Applify template sections anyway (Applify template always
   wins — validation decision V3);
   <!-- Updated: Validation Session 1 - V3 template precedence --> asks user for test-plan
   items (happy + common edge cases) + verified status per item; ticks
   "Unit/integration tests pass" only after actually running tests and records
   the command; writes "None" under Migration/deployment notes (RN project);
   leaves Redmine + Reviewer notes empty; adds reviewers `tomislav-t` and
   `briansonnguyen` via `gh pr create --reviewer`; leaves RAR field for user.
6. Add **S9 — Reviewer add fails gracefully**: `--reviewer` rejected (no
   permission). Expected: reports the failure, still opens/keeps PR, does not
   loop retrying.
7. Optionally run RED arm to record baseline:
   `node tools/run-evals.js --plugin bi-git --skill bi-pr-workflow --dry-run`
   first, then `--ablation` per scenario if API access available; record
   findings in `baseline.md` (dated).

## Success Criteria

- [ ] S4–S9 added, parseable by `node tools/run-evals.js --dry-run`
- [ ] Each brainstorm decision maps to ≥1 expected-behavior checkbox
- [ ] Existing S1–S3 unchanged
- [ ] baseline.md updated or explicitly deferred with reason

## Risk Assessment

- Scenario too easy (agent passes without skill) → sharpen prompt per
  evals/README.md rule; verify via ablation run in phase 3.
