# Changelog — bi-git

## 0.6.0 — 2026-08-07

- `bi-pr-review`: added an advisory **Policy checks** section to the review
  report — commit count (flag when not exactly 1), changed-file count and net
  lines against the POL-ENG-003 thresholds (≤10/≤400 ok, warn zones, >15/>800
  flag; lockfiles+generated excluded), branch-name ticket-id + `feat`/`feature`
  prefix, and PR-title ticket-id + clarity. Mirrors `bi-pr-workflow`'s policy
  but reports it as advisory flags (this skill reviews, it does not gate). New
  reference `policy-checks.md`; scenario S9 added.

## 0.5.0 — 2026-08-07

- `bi-pr-review`: new report-only skill that reviews a branch's diff for bugs,
  regressions, security issues, and scope problems ranked by severity, then
  hands off to `/cook` or `/fix` — never edits code. Auto-detects the review
  target: an open PR is reviewed via `gh pr diff`; a branch with no PR yet is
  reviewed from the local three-dot diff against the locally-resolved default
  branch (plus uncommitted work), so no pull request is required. Complements
  `bi-spec-conformance` (spec-vs-code lane) by owning the general
  correctness/quality/security lane.

## 0.3.0 — 2026-07-20

- `bi-pr-workflow`: refined the Applify PR template to be concise and
  ticket-focused — Summary is 1–3 sentences, Scope names only key
  classes/files or scenarios, and Acceptance criteria are copied verbatim
  from the ticket. Removed the Reviewers and Reviewer notes sections and the
  auto-request-reviewers behavior (reviewer assignment now handled outside
  the skill) (issue #20).

## 0.2.0 — 2026-07-20

- `bi-pr-workflow`: added a non-skippable pre-PR **validate gate** — detect
  and run the project's tests (jest/junit) and lint with hard stop on
  failure, then measure the diff on both POL-ENG-003 metrics (files warn
  >10 / stop >15; net lines excluding lockfiles+generated warn >400 / stop
  >800) with a guided multi-PR split (markdown → UI components → remaining),
  plus POL-ENG-001 branch/ticket/one-increment checks (issue #18).
- `bi-pr-workflow`: PR descriptions now use the embedded **Applify template**
  (always wins over repo templates) via new `references/applify-pr-rules.md`
  — test-plan interview, tests checkbox ticked only from a real run, RN/React
  migration notes "None", default reviewers auto-added with graceful
  degradation, Redmine/Reviewer-notes skipped.

## 0.1.2 — 2026-07-10

- New skill `bi-git-workflow`: param-routed `cp` (stage → layered secret
  scan → conventional commit with ticket id → push) and `pr` (cp path →
  remote-diff PR → template fill → PR link commented on the ticket +
  Development-section branch link). Branch guard covers main/master, the
  repo's default branch, protected patterns, and detached HEAD. Host
  projects override conventions via their declared git rules; safety gates
  are non-overridable. Version set to 0.1.2 by owner decision (issue #6).

## 0.1.0 — 2026-07-05

- Initial release with three skills: `bi-commit-convention`, `bi-rebase-conflict`,
  `bi-pr-workflow`.
