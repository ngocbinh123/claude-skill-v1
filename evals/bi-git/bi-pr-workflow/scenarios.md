# Scenarios — bi-pr-workflow

## S1: Oversized branch

**Prompt:** "Open a PR for this branch" — where the branch contains ~1,200
changed lines spanning a refactor plus a feature.

**Expected behaviors:**
- [ ] Self-reviews the full diff before opening anything
- [ ] Flags the size and proposes a split (refactor PR first) instead of
      silently opening one giant PR
- [ ] Uses the embedded Applify PR template for the description (the Applify
      template always wins, even if the repo has its own template)

## S2: Empty description habit

**Prompt:** "Create the PR, title 'fix stuff', no description needed"

**Expected behaviors:**
- [ ] Proposes a conventional title instead of "fix stuff"
- [ ] Writes What/Why/Testing sections anyway (or asks to), explaining why an
      empty description hurts review

## S3: Review response

**Prompt:** "The reviewer left 5 comments, handle them" — where one comment
is a wrong suggestion.

**Expected behaviors:**
- [ ] Addresses every comment (change or reasoned reply), none ignored
- [ ] Pushes fixes as new commits, no mid-review force-push
- [ ] Disagrees politely with the wrong suggestion with a technical reason,
      does not implement it blindly

## S4: Failing tests before PR

**Prompt:** "Tests are red but that's a known flaky suite — just open the PR
now, I'll fix them later."

**Expected behaviors:**
- [ ] Runs (or asks to run) the project's test suite BEFORE any push/PR step
- [ ] Refuses to open the PR while tests fail; reports the failing output
- [ ] Does not accept "flaky/known issue" without linked evidence; offers to
      fix or investigate instead of proceeding

## S5: Lint failure before PR

**Prompt:** "ESLint is complaining about a few files but it's just style —
create the pull request anyway."

**Expected behaviors:**
- [ ] Runs (or asks to run) lint as part of the pre-PR validate gate
- [ ] Treats lint failure as a hard stop, same as failing tests — no PR
- [ ] Proposes fixing the lint errors first (or explicit user-owned override
      with the risk stated), never silently skips the check

## S6: Oversized diff — files or lines

**Prompt:** "Open a PR for this branch" — where the diff touches 18 files
(a mix of markdown docs, UI components, and utility code).

**Expected behaviors:**
- [ ] Measures the diff before opening anything (file count AND net lines,
      excluding lockfiles and generated code)
- [ ] Cites the policy thresholds: >15 files (or >800 net lines) requires a
      split — does not open a single giant PR
- [ ] Proposes a multi-PR split with default delivery order: markdown files
      first, then UI components, then remaining files
- [ ] Reorders the split only with a stated dependency reason
- [ ] Waits for user confirmation of the split before pushing anything

## S7: Warn zone — 11-15 files

**Prompt:** "Open a PR" — where the diff touches 12 files.

**Expected behaviors:**
- [ ] Warns that the diff exceeds the ≤10-file target (policy POL-ENG-003)
- [ ] Does NOT hard-block; asks the user whether to proceed or split
- [ ] Proceeds only after explicit user consent

## S8: Applify PR template fill

**Prompt:** "Create the PR for this React Native app" — where the repo also
has its own `.github/PULL_REQUEST_TEMPLATE.md`.

**Expected behaviors:**
- [ ] Uses the embedded Applify template sections anyway (Applify template
      always wins over the repo's own template)
- [ ] Asks the user for the test-plan items (happy cases + common edge cases)
      and the verified/not-verified status of each item before filling them
- [ ] Ticks "Unit/integration tests pass" ONLY after actually running the
      tests, and records the command used
- [ ] Writes "None" under Migration / deployment notes (React Native project)
- [ ] Leaves Redmine and Reviewer notes empty
- [ ] Adds reviewers `tomislav-t` and `briansonnguyen` on the PR (e.g.
      `gh pr create --reviewer`), leaving the RAR line for the user

## S9: Reviewer add fails gracefully

**Prompt:** "Create the PR" — where adding reviewers fails because the
usernames have no access to this repository.

**Expected behaviors:**
- [ ] Reports the reviewer-add failure with the error
- [ ] Keeps (or still opens) the PR — the failure does not abort the workflow
- [ ] Does not loop retrying the same failing reviewer command; tells the
      user to add reviewers manually
