---
name: bi-pr-review
description: Review the diff that will become (or already is) a pull request and report bugs, regressions, security issues, and scope problems ranked by severity — never edits code. Auto-detects an open PR (reviews via gh) vs a local branch with no PR yet (reviews the branch diff). Use when reviewing a PR before or after it is opened, when the user says "review my PR", "review before PR", "review this branch", "pr review", "review my changes", or wants a code review of a branch that has no pull request yet.
---

# bi-pr review (branch / PR code review)

## Overview

Review the changes that will become — or already are — a pull request, and
report where they are wrong or risky. Each finding gets one severity and cited
evidence (`file:line` + a concrete failure scenario). **This skill never edits
code, never approves, never merges**: it writes a review report and hands off to
`/cook` or `/fix`.

Core principle: review what the reviewer will actually see. A PR need NOT exist —
if there is no open PR, review the local branch diff. This skill owns the
**general correctness / quality / security** lane; spec-vs-code conformance
belongs to `bi-spec-conformance`, not here.

## Workflow

1. **Resolve the review target** (auto-detect PR vs local). See below.
2. **Read the changed files** for context, not only the raw hunks.
3. **Review across the dimensions** and assign severity + evidence. See
   `references/review-dimensions.md`.
4. **Write the report** (skeleton below) and hand off to `/cook` or `/fix`.

## 1. Resolve the review target (auto-detect)

Decide the diff source WITHOUT assuming a PR exists:

- **Open PR?** Check with `gh pr view --json number,url,baseRefName` (or the
  number the user gave). If one exists, review the **actual PR diff**:
  `gh pr diff <number>` against its base — this is what reviewers see.
- **No PR (or no `gh`)?** Review the **local branch** against the default
  branch. Determine the default branch **locally**
  (`git symbolic-ref refs/remotes/origin/HEAD` → e.g. `origin/master`), no
  network guess, never assume `main`. Use the **three-dot** form
  `git diff <default>...HEAD` (never two-dot). If there are uncommitted changes,
  include the working tree too (staged + unstaged + untracked) **in addition to**
  the committed diff.
- Do NOT create a PR, push, or open anything just to review it.
- Escape hatch: `--files <paths>` to scope the review to given files.

Full detection rules and commands: `references/resolve-target.md`.

## 2. Review dimensions (summary)

Assess the diff through these lenses, correctness first (full checklist +
worked examples in `references/review-dimensions.md`):

| Lens | Looks for |
|------|-----------|
| Correctness | Logic bugs, null/undefined, off-by-one, wrong condition/branch |
| Regressions | Broken callers, changed contracts, removed guards |
| Security | Injection, auth/permission gaps, secret exposure, unsafe input |
| Error handling | Swallowed errors, unhandled rejections, missing edge cases |
| Tests | New/changed behavior without matching tests |
| Scope | Unrelated drive-by changes mixed into the diff |
| Readability | Only when it genuinely impairs review — never as a blocker |

**Severity tiers:** 🔴 blocker · 🟠 high · 🟡 medium · 🟢 low. Rank findings
most-severe first.

Two non-negotiable rules:

- **Evidence required.** No finding without `file:line` **and** a concrete
  failure scenario (inputs/state → wrong output/crash). "Looks risky" with no
  reproduction is not a finding. No evidence ⇒ drop it.
- **Correctness over taste.** Pure style/formatting/naming preference is never
  blocker/high — send mechanical style to the project's linter/formatter, not a
  hand-listed nitpick pile. A clean diff → report "no blocking issues"; do not
  invent findings to pad the report.

## 3. Report + hand-off

Write the report to `plans/reports/pr-review-{YYMMDD}-{slug}.md` (or next to a
spec/ticket if the user names a location). Use this skeleton exactly:

```markdown
# PR Review — {branch or PR #}

- **Target:** {gh pr diff <n> | git diff <default>...HEAD (+ working tree)}
- **Base:** {default branch} · **Date:** {YYMMDD}
- **Verdict:** {Approve / Approve with nits / Changes requested}

## Summary
{1–3 sentences: what the change does + the headline risk, if any.}

## Findings
| Severity | Finding (file:line) | Failure scenario | Suggested fix |
|----------|---------------------|------------------|---------------|
| 🔴 | `path:line` — one-line claim | inputs/state → wrong result | direction only |

_(No blocking issues → say so and list only 🟡/🟢 if any.)_

## Scope note
{Unrelated changes to split out, or "Single logical concern.".}

## Hand-off
Run `/cook` or `/fix` with this report to apply fixes. This review edited no code.

## Unresolved questions
{Runtime-dependent claims needing the author's input, or "None".}
```

For runtime-dependent claims (could-fail-depending-on-state), present them as
**questions**, not hard-asserted findings. Overwrite guard + full contract:
`references/report-template.md`.

## Verification

Before finishing, confirm:
- [ ] Review target auto-detected: open PR → `gh pr diff`; else three-dot local
      diff vs the **locally-resolved** default branch (+ working tree).
- [ ] No PR was created and nothing was pushed to produce the review.
- [ ] Every finding has `file:line` + a concrete failure scenario; ranked
      most-severe first.
- [ ] Style preferences were not raised as blocker/high.
- [ ] No source file was edited; report written; hand-off to `/cook` or `/fix`.

## Anti-patterns

- **Do NOT** stop or error with "no PR found" — fall back to the local branch
  diff; a PR is not required.
- **Do NOT** edit code, commit, push, approve, or merge — report + suggested
  direction only.
- **Do NOT** report a finding without `file:line` + a concrete failure scenario;
  no "looks risky" hand-waving.
- **Do NOT** raise pure style/formatting/naming as blocker/high — defer
  mechanical style to the linter/formatter.
- **Do NOT** invent findings to fill the report — "no blocking issues" is a
  valid result.
- **Do NOT** hard-assert runtime-dependent claims — surface them as questions.
- **Do NOT** drift into spec-conformance (that is `bi-spec-conformance`) or into
  the PR-creation validate gate (that is `bi-pr-workflow`).
- **Do NOT** two-dot the diff or assume `main` — three-dot against the
  locally-resolved default branch.
