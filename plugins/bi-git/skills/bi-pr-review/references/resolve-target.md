# Resolving the review target (PR vs local branch)

The skill reviews whatever the reviewer will actually see. Detect the source in
this order; never assume a PR exists and never assume the default branch is
`main`.

## Step 1 — Is there an open PR?

```bash
# Explicit number the user gave, e.g. "review PR #42"
gh pr view 42 --json number,url,baseRefName,state

# Or the PR for the current branch
gh pr view --json number,url,baseRefName,state
```

- Exit 0 with `state == OPEN` ⇒ **PR path** (Step 2A).
- Non-zero / "no pull requests found" / `gh` not installed / not authenticated
  ⇒ **local path** (Step 2B). Do not treat the missing PR as an error.

## Step 2A — PR path

Review the real PR diff so the review matches GitHub:

```bash
gh pr diff 42            # unified diff of the PR against its base
gh pr view 42 --json title,body,files,additions,deletions
```

Read the changed files in the checkout for context. Do not modify the PR, its
branch, or its state.

## Step 2B — Local path (no PR yet)

Resolve the default branch **locally**, then three-dot diff:

```bash
# Default branch, no network call:
git symbolic-ref refs/remotes/origin/HEAD --short   # e.g. origin/master
# Fallbacks if the symbolic ref is unset:
#   git remote show origin | sed -n 's/.*HEAD branch: //p'   (network)
#   or ASK the user which branch to compare against.

BASE=origin/master                # from the command above
git diff "$BASE"...HEAD           # THREE dots — commits unique to this branch
```

Three dots (`BASE...HEAD`) diff against the merge-base, i.e. only what this
branch introduced — the same set a PR would show. Two dots would also show
changes that landed on the base since you branched: noise. Never use two dots.

Include uncommitted work when present, in addition to the committed diff:

```bash
git status --porcelain            # any output ⇒ working tree has changes
git diff                          # unstaged
git diff --cached                 # staged
# untracked files: read them directly
```

## Step 3 — Escape hatch

`--files <paths>` scopes the review to the given files only (still read them
fully for context). Use when the user wants a targeted review rather than the
whole branch.

## Never

- Never `gh pr create`, `git push`, or open anything to produce a review.
- Never require a PR — the local path is a first-class mode, not a degraded one.
- Never assume `main`; resolve the default branch from the repo.
