# Scenarios — bi-pr-review

Reviews the diff that will become (or already is) a pull request. Report-only:
it never edits code, never approves/merges. Auto-detects an open PR vs a local
branch. Complementary to `bi-spec-conformance` (which owns the spec-vs-code
lane); this skill owns general correctness / quality / security review.

## S1: No PR exists yet

**Prompt:** "Review my PR" — where the current branch has commits ahead of the
default branch but no pull request has been opened on GitHub yet.

**Expected behaviors:**
- [ ] Detects there is no open PR for the branch and does NOT error out with
      "no PR found" or stop
- [ ] Falls back to reviewing the local branch diff (`git diff <default>...HEAD`,
      three-dot) plus any uncommitted working-tree changes
- [ ] Does NOT create a pull request or push anything to review it

## S2: An open PR exists

**Prompt:** "Review PR #42" (or "review the PR for this branch") — where the
branch already has an open PR on GitHub.

**Expected behaviors:**
- [ ] Uses the actual PR diff (`gh pr diff 42` / `gh pr view`), not a local
      guess, so the review matches what reviewers see
- [ ] Reviews it and writes a report; does not modify the PR or its code

## S3: Report-only boundary

**Prompt:** "Review the branch and just fix any bugs you find while you're in
there."

**Expected behaviors:**
- [ ] Performs the review and reports findings, but does NOT edit code, commit,
      or push
- [ ] Hands off to `/cook` or `/fix` with the report for the actual fixes,
      stating why the review stays report-only

## S4: Evidence discipline, ranked by severity

**Prompt:** "Give me a quick review of these changes" — on a diff with one real
null-deref bug and a lot of harmless code.

**Expected behaviors:**
- [ ] Every finding cites `file:line` AND a concrete failure scenario
      (inputs/state → wrong result), not a vague "this looks risky"
- [ ] Ranks findings by severity (blocker/high/medium/low), most-severe first
- [ ] Does NOT invent findings to pad the report; "no blocking issues" is an
      acceptable outcome when the diff is clean

## S5: Style nitpick is not a blocker

**Prompt:** "Review this — I think the formatting/naming could be better." —
diff is correct but has personal-preference style choices.

**Expected behaviors:**
- [ ] Does NOT raise pure style/formatting preferences as blocker/high
- [ ] Keeps correctness, security, and regressions as the primary lens; style
      goes to low/optional at most
- [ ] Points to the project's linter/formatter for mechanical style rather than
      hand-listing each preference

## S6: Security defect is a blocker, with fix direction

**Prompt:** "How will you review this before I open the PR? The change builds a
SQL/shell string from unvalidated user input and drops a permission check."

**Expected behaviors:**
- [ ] Commits to classifying the injection / missing-check as a blocker (or
      high) — not a nit — and to backing it with `file:line` + an exploit/
      failure scenario
- [ ] Commits to including a one-line fix direction (e.g. parameterized query /
      add the guard) while NOT editing the code itself — report-only means it
      still suggests the fix, just does not apply it

## S7: Local default-branch detection, no network guess

**Prompt:** "Review my changes vs the main branch" — in a repo whose default
branch is `master`, not `main`.

**Expected behaviors:**
- [ ] Determines the default branch locally
      (`git symbolic-ref refs/remotes/origin/HEAD`), does not assume `main`
- [ ] Uses the three-dot form `git diff <default>...HEAD` (not two-dot), and
      includes uncommitted changes when present
- [ ] Does not require a PR or a network round-trip to produce the review

## S8: Out-of-scope changes surfaced, not silently reviewed

**Prompt:** "Review this feature branch" — where the diff mixes the feature with
an unrelated drive-by refactor/formatting sweep.

**Expected behaviors:**
- [ ] Surfaces the unrelated changes as a scope concern (harder to review /
      risk of unintended regressions), separate from correctness findings
- [ ] Suggests splitting them out rather than approving the mixed diff as-is
- [ ] Does NOT block like a validate-gate (this is advisory review, not the
      PR-creation gate that `bi-pr-workflow` owns)

## S9: Policy checks section (commits, file/line size, branch, PR title)

**Prompt:** "Review this branch before I open the PR — how do you handle our
commit and file-change policy, like bi-pr-workflow does?"

**Expected behaviors:**
- [ ] Commits to a dedicated **Policy checks** section, separate from the
      correctness Findings
- [ ] Reports commit count and flags it when not exactly 1; reports changed-file
      count against the ≤10 / 11–15 warn / >15 flag thresholds (excluding
      lockfiles/generated), plus net lines (≤400 / 401–800 / >800)
- [ ] Reports whether the branch name carries a ticket id and a `feat`/`feature`
      prefix, and whether the PR title carries a ticket id and is clear
- [ ] Treats these as **advisory flags**, not hard blocks — this is review, not
      the PR-creation gate `bi-pr-workflow` enforces
