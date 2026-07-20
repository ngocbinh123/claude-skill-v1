---
title: 'bi-pr-workflow: Applify validate gate + PR template'
description: >-
  Add pre-PR validate gate (test/lint/size per POL-ENG-001/003) and Applify PR
  template auto-fill to bi-pr-workflow, eval-first (TDD)
status: completed
priority: P2
branch: feature/CS-18-main-add-validate-gate-applify-pr-template-to-bi-pr-workflow
tags:
  - bi-git
  - skill
  - tdd
blockedBy: []
blocks: []
created: '2026-07-20T05:05:58.005Z'
createdBy: 'ck:plan'
source: skill
---

# bi-pr-workflow: Applify validate gate + PR template

**Ticket:** ngocbinh123/claude-skill-v1#18
(<https://github.com/ngocbinh123/claude-skill-v1/issues/18>) —
work branch: `feature/CS-18-main-add-validate-gate-applify-pr-template-to-bi-pr-workflow`

## Overview

Update skill `plugins/bi-git/skills/bi-pr-workflow` per approved brainstorm:
[brainstorm report](../reports/brainstorm-260720-1151-bi-pr-workflow-applify-validate-gate-report.md).

Delivers:
1. **Validate gate** before opening any PR: run tests (jest/junit by project
   type) → lint (hard stop on fail) → size check per POL-ENG-003 on BOTH
   metrics — files (`warn >10`, `stop >15`) AND net lines excluding
   lockfiles/generated (`warn >400`, `stop >800`) — split order markdown →
   UI components → remaining →
   POL-ENG-001 checks (not on main, ticket id in branch, one releasable increment).
2. **Applify PR creation**: embedded Applify template in new
   `references/applify-pr-rules.md` with fill rules (test plan interview,
   auto-run tests + tick checkbox, RN/React → Migration "None", auto reviewers
   `tomislav-t` + `briansonnguyen`, skip Redmine + Reviewer notes).
   **Template precedence: the embedded Applify template ALWAYS wins**, even
   over a repo's `.github/PULL_REQUEST_TEMPLATE*` (validation decision V3 —
   supersedes the current SKILL.md "repo template WINS" rule).

Hard constraints (repo governance): eval scenarios BEFORE SKILL.md changes;
frontmatter = `name` + `description` only with "Use when ..."; body ≤ 500 lines;
version bump in plugin.json only then `node tools/sync-versions.js`.

User-accepted trade-off: Applify specifics (reviewer usernames) hardcoded in
published skill — reviewer change requires new release.

## Phases

| Phase | Name | Status |
|-------|------|--------|
| 1 | [Evals RED - scenarios first](./phase-01-evals-red-scenarios-first.md) | Completed |
| 2 | [Skill GREEN - SKILL.md + applify references](./phase-02-skill-green-skill-md-applify-references.md) | Completed |
| 3 | [Verify - version bump + gates + evals](./phase-03-verify-version-bump-gates-evals.md) | Completed |

## Dependencies

- None cross-plan (plans/ contained only reports/).
- Policy sources (read-only, external):
  `/Users/binhnguyen/Documents/projects/applify-gov/policies/engineering/git-and-code-review.md`,
  `.../pull-request-size.md`, template `.../templates/pull-request.md`.

## Acceptance criteria (whole plan)

- [x] New scenarios in `evals/bi-git/bi-pr-workflow/scenarios.md` cover: gate
      blocks on failing tests/lint; >15 files OR >800 net lines → split
      proposal with default order; Applify template fill (wins over repo
      template); auto reviewers; RN → Migration "None" (S4–S9 + S1 amended)
- [x] SKILL.md contains validate gate + Applify PR creation, 132 lines (≤500),
      valid frontmatter with "Use when ..."
- [x] `references/applify-pr-rules.md` holds embedded template + fill rules
- [x] bi-git version bumped minor (0.1.2 → 0.2.0), marketplace synced
- [x] Static gates pass: `node tools/lint-frontmatter.js && node tools/check-governance.js && node tools/sync-versions.js --check`
- [x] `node tools/run-evals.js --plugin bi-git --skill bi-pr-workflow` passes (9/9 scenarios)

## Implementation result

All 3 phases completed on branch
`feature/CS-18-main-add-validate-gate-applify-pr-template-to-bi-pr-workflow`.

- Evals: 9/9 with-skill scenarios pass (`evals/results/2026-07-20T07-09-42-721Z/`).
- Code review (code-reviewer subagent): all acceptance criteria PASS, static
  gates 3/3. One out-of-scope concern — sibling skill `bi-git-workflow`
  (`workflow-pr.md`) keeps "repo template WINS", contradicting V3. User
  decision: keep scoped, add a scoping note to BOTH skills (done) rather than
  reconcile now.

## Open questions

- Exact test/lint commands per Applify repo — skill must fall back to asking
  the user when detection fails (documented in phase 2).

## Validation Log

### Session 1 — 2026-07-20 (validate interview)

#### Verification Results
- Claims checked: 10
- Verified: 9 | Failed: 0 | Unverified: 1 (`--retries` flag not found in
  `tools/run-evals.js` source; mentioned only in evals/README.md — phase 3
  risk note softened accordingly)
- Tier: Standard (3 phases)

#### Decisions
- **V1 — Lint fail = hard stop** (same as failing tests). Confirmed plan as
  written; no change.
- **V2 — Size gate checks BOTH file count (10/15) and net lines (400/800,
  excluding lockfiles + generated code per POL-ENG-003)**. Supersedes the
  brainstorm decision "file count only".
- **V3 — Applify embedded template ALWAYS wins**, including over a repo's
  `.github/PULL_REQUEST_TEMPLATE*`. Supersedes both the brainstorm precedence
  and the current SKILL.md "template check comes FIRST / repo template WINS"
  rule — phase 2 must rewrite that SKILL.md section.

#### Whole-Plan Consistency Sweep
- Propagated V2 to phase-01 (S6 line-threshold expectations) and phase-02
  (gate step 4 dual metric).
- Propagated V3 to phase-02 (architecture precedence + SKILL.md rewrite step);
  removed stale "repo template WINS" wording from plan and phases.
- Sweep caught: existing eval S1 expectation "Checks for a repo PR template
  and follows it" contradicts V3 → phase-01 now amends S1 accordingly.
- Softened `--retries` claim in phase-03 risk note.
- No unresolved contradictions remain.
