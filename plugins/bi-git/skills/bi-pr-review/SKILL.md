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

**Report-only ≠ silent.** Every finding still carries a **one-line fix
direction** — what to change, not a patch. "Report-only" means this skill does
not *apply* the fix (no code edits); it always *suggests* the direction and
hands the actual editing to `/cook` or `/fix`. Suggesting a direction is not
editing code — never omit it.

## Workflow

1. **Resolve the review target** (auto-detect PR vs local). See below.
2. **Read the changed files** for context, not only the raw hunks.
3. **Review across the dimensions** and assign severity + evidence. See
   `references/review-dimensions.md`.
4. **Run the policy checks** (advisory) — commits, size, branch, PR title. See
   `references/policy-checks.md`.
5. **Write the report** (skeleton below) and hand off to `/cook` or `/fix`.

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

## 3. Policy checks (advisory)

Report compliance against the same policy `bi-pr-workflow` enforces — but here
it is **advisory**: flag violations, do NOT hard-block (this is review, not the
PR-creation gate). Compute from the resolved target (full commands + thresholds
in `references/policy-checks.md`):

| Check | Rule | How |
|-------|------|-----|
| Commits | exactly **1** commit; flag otherwise | `git rev-list --count <base>..HEAD` or `gh pr view --json commits` |
| Files changed | ≤10 ok · 11–15 warn · **>15 flag** (excl. lockfiles/generated) | `git diff --name-only <base>...HEAD` |
| Net lines | ≤400 ok · 401–800 warn · **>800 flag** | `git diff --numstat <base>...HEAD` summed |
| Branch name | carries a **ticket id** AND a `feat`/`feature` prefix | current branch / PR head ref |
| PR title | carries a **ticket id** and is clear & concise | `gh pr view --json title` (PR mode only) |
| One concern | single logical change, not feature + drive-by | from the Scope lens |

Each row reports its actual value and a ✅/⚠️/flag. These are compliance signals
for the author, never a reason this skill refuses to produce the review.

## 4. Report + hand-off

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

## Policy checks
| Check | Value | Status |
|-------|-------|--------|
| Commits | {n} | {✅ / ⚠️ not 1} |
| Files changed | {n} | {✅ ≤10 / ⚠️ 11–15 / 🚩 >15} |
| Net lines | {n} | {✅ / ⚠️ / 🚩} |
| Branch name | {name} | {✅ ticket+prefix / ⚠️ missing …} |
| PR title | {title / n/a} | {✅ / ⚠️ …} |

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
- [ ] Every finding has `file:line` + a concrete failure scenario + a one-line
      fix direction; ranked most-severe first.
- [ ] Style preferences were not raised as blocker/high.
- [ ] Policy checks reported (commits, files, lines, branch, PR title) as
      advisory flags — not used to block the review.
- [ ] No source file was edited; report written; hand-off to `/cook` or `/fix`.

## Anti-patterns

- **Do NOT** stop or error with "no PR found" — fall back to the local branch
  diff; a PR is not required.
- **Do NOT** edit code, commit, push, approve, or merge — but DO give a one-line
  fix direction per finding. Report-only means "don't apply the fix", not
  "don't suggest one".
- **Do NOT** report a finding without `file:line` + a concrete failure scenario;
  no "looks risky" hand-waving.
- **Do NOT** raise pure style/formatting/naming as blocker/high — defer
  mechanical style to the linter/formatter.
- **Do NOT** invent findings to fill the report — "no blocking issues" is a
  valid result.
- **Do NOT** hard-assert runtime-dependent claims — surface them as questions.
- **Do NOT** hard-block on a policy violation — report it in the Policy checks
  section as an advisory flag. The blocking gate is `bi-pr-workflow`'s job at
  PR-creation time; this skill reviews and reports, it does not gate.
- **Do NOT** drift into spec-conformance — that is `bi-spec-conformance`.
- **Do NOT** two-dot the diff or assume `main` — three-dot against the
  locally-resolved default branch.
