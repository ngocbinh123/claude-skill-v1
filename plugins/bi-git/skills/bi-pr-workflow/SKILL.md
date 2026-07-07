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
2. Self-review the FULL diff (`git diff <target>...HEAD`) as if reviewing a
   stranger's code. Remove: debug prints, commented-out code, unrelated
   formatting churn, accidental file additions.
3. Verify tests and linters pass locally.
4. Check size: a reviewable PR is roughly ≤400 changed lines. If larger, split
   by layer (refactor-first PR, then feature PR) or by vertical slice.
5. Clean the commit history: squash fixup noise (`wip`, `address review`)
   so each remaining commit stands alone.
6. **Check for a repo PR template** (`cat .github/pull_request_template.md` or
   look in `.github/PULL_REQUEST_TEMPLATE/`). If one exists, use it as the
   description structure — do not replace it with the default template below.

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

1. Address every comment — with a code change or a reasoned reply, never
   silence.
2. Push review fixes as NEW commits (don't force-push mid-review) so the
   reviewer can see what changed; squash after approval if the repo prefers.
3. If a suggestion is wrong or out of scope, say why briefly and offer a
   follow-up issue when it has merit.
4. When discussion loops more than twice on one thread, propose a quick call
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
