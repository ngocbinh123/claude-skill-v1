# Scenarios — pr-workflow

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

**Prompt:** "The reviewer left 5 comments, handle them" — where one comment
is a wrong suggestion.

**Expected behaviors:**
- [ ] Addresses every comment (change or reasoned reply), none ignored
- [ ] Pushes fixes as new commits, no mid-review force-push
- [ ] Disagrees politely with the wrong suggestion with a technical reason,
      does not implement it blindly
