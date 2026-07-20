# bi-pr-workflow: validate gate + Applify PR template

Date: 2026-07-20 | Issue: #18 | Commit: c69bf2c |
Branch: feature/CS-18-main-add-validate-gate-applify-pr-template-to-bi-pr-workflow

## What shipped

`bi-pr-workflow` (plugin bi-git, 0.1.2 → 0.2.0) gained a non-skippable pre-PR
validate gate and an Applify-specific PR template:

- **Validate gate**: detect+run tests (jest/junit) and lint, hard-stop on
  fail; diff-size check on BOTH POL-ENG-003 metrics — files (warn >10 / stop
  >15) and net lines excl. lockfiles+generated (warn >400 / stop >800); on
  stop, guided multi-PR split markdown → UI components → remaining; plus
  POL-ENG-001 branch/ticket/one-increment checks.
- **Applify PR creation** via new `references/applify-pr-rules.md`: embedded
  template that always wins over repo templates, test-plan interview,
  tests-checkbox ticked only from a real run, RN/React → Migration "None",
  default reviewers `tomislav-t`+`briansonnguyen` (RAR left for user, graceful
  degrade), Redmine/Reviewer-notes skipped.

## Decisions

- **V2** (validate interview): size gate checks both file count and net lines,
  not file count alone.
- **V3**: Applify template overrides repo `.github/PULL_REQUEST_TEMPLATE*` —
  reverses the skill's prior "repo template WINS" rule.
- Applify specifics hardcoded in the published skill (user-accepted): changing
  reviewers requires a new release.
- Cross-skill contradiction found in review — sibling `bi-git-workflow` keeps
  "repo template wins". User chose to keep the two scoped to different
  contexts and add an explicit scoping note to each skill rather than
  reconcile now.

## Process notes

- Built test-first per repo governance: eval scenarios S4–S9 (+amended S1)
  written before SKILL.md. Runner: 9/9 with-skill scenarios pass.
- S8 failed once — agent asked the user instead of writing RN Migration
  "None". Fixed by making the instruction directive ("write None directly, do
  NOT ask") in both SKILL.md and the reference; re-ran S8 → 6/6.
- Static gates (lint-frontmatter, check-governance, sync-versions --check)
  green; SKILL.md 132/500 lines.

## Open follow-ups

- Whether to unify PR-template precedence across `bi-pr-workflow` and
  `bi-git-workflow` — deferred, scoping notes added meanwhile.
- Per-repo test/lint command detection relies on an ASK fallback; real Applify
  repo commands not yet enumerated.
