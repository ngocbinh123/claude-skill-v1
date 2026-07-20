---
phase: 2
title: Skill GREEN - SKILL.md + applify references
status: completed
effort: M
dependencies:
  - 1
---

# Phase 2: Skill GREEN - SKILL.md + applify references

## Overview

TDD GREEN: update SKILL.md with the validate gate + Applify PR creation flow,
and create `references/applify-pr-rules.md` holding the embedded Applify
template + fill rules, until phase-1 scenarios pass.

## Requirements

- Functional: implement all behaviors from S4–S9.
- Non-functional: SKILL.md body ≤ 500 lines (depth → references/); frontmatter
  exactly `name` + `description` with a "Use when ..." trigger phrase
  (mention new triggers: validate gate, Applify PR); keep existing sections
  (title convention, responding-to-review, anti-patterns) — EXCEPT the
  template-precedence paragraph, which is rewritten per V3.
  <!-- Updated: Validation Session 1 - V3 -->

## Architecture

- SKILL.md = behavior + ordering; `references/applify-pr-rules.md` = Applify
  specifics (embedded template, per-section fill rules, hardcoded reviewers).
  Mirrors bi-git-workflow's SKILL.md + references/ layout.
- Precedence: **the embedded Applify template ALWAYS wins**, even when the
  repo has its own `.github/PULL_REQUEST_TEMPLATE*` (validation decision V3).
  The existing SKILL.md "Template check comes FIRST / repo template WINS"
  paragraph must be REWRITTEN, not kept.
  <!-- Updated: Validation Session 1 - V3 template precedence -->

## Related Code Files

- Modify: `plugins/bi-git/skills/bi-pr-workflow/SKILL.md`
- Create: `plugins/bi-git/skills/bi-pr-workflow/references/applify-pr-rules.md`

## Implementation Steps

1. SKILL.md — insert **"Validate gate (before opening any PR)"** section after
   "Before opening the PR", ordered and non-skippable:
   1. Detect project type: `package.json` → `npm test`/jest; `build.gradle`/
      `pom.xml` → junit via gradle/maven. Detection fails → ASK user for the
      test command; never silently skip.
   2. Run tests → any fail ⇒ STOP, report, do not open PR.
   3. Run lint (`npm run lint` / detected linter) → fail ⇒ STOP, report.
   4. Size check on BOTH metrics <!-- Updated: Validation Session 1 - V2 -->:
      - Files: `git diff --name-only <target>...HEAD | wc -l` — ≤10 pass;
        11–15 warn citing POL-ENG-003 target, proceed only with user consent;
        >15 STOP.
      - Net lines: `git diff --numstat <target>...HEAD` summed, EXCLUDING
        lockfiles (`package-lock.json`, `yarn.lock`, `poetry.lock`, …) and
        auto-generated code — ≤400 pass; 401–800 warn; >800 STOP.
      - Any STOP → propose multi-PR split, default delivery order markdown →
        UI components → remaining; may reorder only with stated dependency
        reason; user confirms before any push.
   5. Policy checks: not on main/master; branch carries ticket id; diff is one
      logical concern / one releasable increment.
2. SKILL.md — add **"Applify PR creation"** section: after gate passes, follow
   `references/applify-pr-rules.md` for description + reviewers. REWRITE the
   existing "Template check comes FIRST" paragraph: the embedded Applify
   template always wins (even over repo `.github/PULL_REQUEST_TEMPLATE*`);
   generic What/Why/How fallback only if the reference file is missing.
   <!-- Updated: Validation Session 1 - V3 template precedence -->
3. Create `references/applify-pr-rules.md`:
   - Embedded Applify template (from applify-gov `templates/pull-request.md`).
   - Fill rules table: Summary+Closes/Refs from diff+ticket; Scope with
     out-of-scope; Acceptance criteria = this PR's subset; Test plan =
     interview user for happy + common edge cases, per-item verified status,
     tick accordingly; "Unit/integration tests pass" auto-ticked ONLY from the
     gate's real run + record command; Links: Spec if any, Redmine skip;
     Screenshots mandatory when diff touches UI; Migration notes: backend →
     ask, React/React Native → write "None"; Reviewer notes: leave empty.
   - Reviewers: `gh pr create --reviewer tomislav-t --reviewer briansonnguyen`;
     RAR line in body left for the user (exactly 1 RAR, never the author);
     on `--reviewer` failure: report and continue, no retry loop.
4. Update SKILL.md `description` frontmatter to include new triggers while
   keeping "Use when ..." phrasing.
5. Add anti-patterns: never open PR on red tests ("just this once"), never
   auto-fill test-plan verified status without asking, never tick the tests
   checkbox without a real run.
6. Re-run phase-1 scenarios (manual or runner) → iterate until GREEN;
   REFACTOR loopholes into anti-patterns per evals/README.md.

## Success Criteria

- [ ] All S1–S9 scenarios pass with skill injected
- [ ] SKILL.md ≤ 500 lines, frontmatter lints clean
- [ ] references/applify-pr-rules.md self-contained (template + rules)
- [ ] Existing behaviors (S1–S3) not regressed

## Risk Assessment

- Body growth beyond 500 lines → push detail to references early.
- Hardcoded reviewers (accepted): document in reference file header that
  changing reviewers requires a version bump.
- Test-command detection wrong in monorepos → explicit ASK fallback is the
  documented behavior, not best-effort guessing.
