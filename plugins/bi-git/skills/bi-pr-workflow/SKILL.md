---
name: bi-pr-workflow
description: Prepare branches and open well-structured pull requests, including self-review and responding to review feedback. Use when creating a pull request, preparing a branch for review, writing a PR description, or addressing reviewer comments.
---

# Pull Request Workflow

## Overview

A PR is a communication artifact, not a code dump. Optimize for the reviewer:
small scope, clear narrative, zero surprises.

## Before opening the PR

1. Rebase onto the latest target branch so the diff contains only your change.
2. **Run `git diff <target>...HEAD --stat` and then `git diff <target>...HEAD`
   to review the FULL diff** as if reviewing a stranger's code. Read and report
   findings before taking any further action — call out debug prints,
   commented-out code, unrelated formatting churn, accidental file additions.
3. **Count changed lines** (from `--stat` output). If the total exceeds ~400
   lines, **stop and flag this** to the user: state the actual line count,
   identify whether the branch mixes concerns (e.g. refactor + feature), and
   propose splitting into separate PRs (refactor-first, then feature) before
   opening anything.
4. Verify tests and linters pass locally.
5. Clean the commit history: squash fixup noise (`wip`, `address review`)
   so each remaining commit stands alone.
6. **Check for a repo PR template**: run
   `cat .github/pull_request_template.md 2>/dev/null || cat .github/PULL_REQUEST_TEMPLATE/*.md 2>/dev/null`
   and state whether one was found. If one exists, use it as the description
   structure — do not replace it with the default template below.

## PR title and description

Title follows the same convention as commits: `type(scope): subject`.

Description template (use when the repo has no PR template):

```markdown
## What
One or two sentences: the change from the user's/system's perspective.

## Why
The problem or requirement. Link the issue: Closes #123.

## How
Only the non-obvious decisions: trade-offs, alternatives rejected, anything
a reviewer would otherwise have to reverse-engineer from the diff.

## Testing
How this was verified: tests added, manual steps run, screenshots for UI.

## Risk / rollout
Migrations, feature flags, backward compatibility, revert plan — if relevant.
```

Rules:

- The description must be understandable WITHOUT reading the diff.
- Screenshots/recordings are mandatory for visual changes (before/after).
- Call out the parts you are unsure about — directing reviewer attention is a
  strength, not a weakness.

## Responding to review

1. **List every comment first.** Before touching any code, enumerate all
   review comments and evaluate each one:
   - Mark it as **implement**, **reply-only**, or **push back** (technically
     wrong or out of scope).
   - Never skip or silently ignore a comment.
2. **Evaluate correctness before implementing.** If a suggestion is
   technically wrong (e.g. it would break behavior, misunderstands a
   constraint, or violates a project convention), do NOT implement it.
   Instead, reply with a brief technical reason — state the specific issue
   and, when the suggestion has merit, offer a follow-up issue.
3. **State your commit strategy upfront**: fixes will be pushed as NEW
   commits (one per logical change) so the reviewer can see what changed.
   Never force-push while review is open; squash only after approval if the
   repo prefers it.
4. Work through every comment from your plan — each comment receives either
   a code change (committed separately) or a written reply, with nothing
   left unaddressed.
5. When discussion loops more than twice on one thread, propose a quick call
   or defer to the repo's convention/owner — comment threads are a bad place
   for design debates.

## Anti-patterns

- Do NOT open a PR whose description is empty or just repeats the title.
  An empty description leaves reviewers without context for the change, makes
  git history harder to navigate later, and forces future contributors to
  reverse-engineer intent from the diff alone. Always write at least a What and
  Why, even for small changes.
- Do NOT mix "drive-by" fixes into a feature PR — separate PR, easy approve.
- Do NOT mark threads resolved on the reviewer's behalf without a change or
  an agreed reply.
- Do NOT merge on red or flaky CI ("it's unrelated") without linking evidence
  that the failure is a known issue.
