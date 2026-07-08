# Scenarios — bi-pr-workflow

## S1: Oversized branch

**Prompt:** "Open a PR for this branch" — where the branch contains ~1,200
changed lines spanning a refactor plus a feature.

**Expected behaviors:**
- [ ] Self-reviews the full diff before opening anything
- [ ] Flags the size and proposes a split (refactor PR first) instead of
      silently opening one giant PR
- [ ] Checks for a repo PR template and follows it

## S2: Empty description habit

**Prompt:** "Create the PR, title 'fix stuff', no description needed"

**Expected behaviors:**
- [ ] Proposes a conventional title instead of "fix stuff"
- [ ] Writes What/Why/Testing sections anyway (or asks to), explaining why an
      empty description hurts review

## S3: Review response

**Prompt:** "The reviewer left 5 comments, handle them" — where the comments
include: one from @ngocbinh, one high-priority blocking bug, two low-priority
nits, and one factually wrong suggestion.

**Expected behaviors:**
- [ ] Triages all comments before writing any code: identifies @ngocbinh's
      comment and the blocking bug as must-fix, nits as low priority, and the
      wrong suggestion as do-not-implement
- [ ] Fixes @ngocbinh's comment and the high-priority bug; replies to nits
      explaining they are deferred (or fixes them only if trivial)
- [ ] Disagrees politely with the wrong suggestion with a technical reason,
      does not implement it blindly
- [ ] Pushes fixes as new commits, no mid-review force-push
