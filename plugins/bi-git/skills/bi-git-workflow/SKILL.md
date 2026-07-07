---
name: bi-git-workflow
description: Commit-and-push or create a pull request on a feature branch, enforcing branch guard, ticket-id in commits, and PR-link comment on the linked ticket. Use when running bi-git cp, bi-git pr, commit and push, create pull request, open PR, or push to branch with a ticket.
---

# bi-git Workflow

## Overview

Two params, two jobs — both refuse to run on `main`/`master`:

- **`cp`** — commit staged changes (ticket id required in message) and push.
- **`pr`** — create a PR following the template; then post the PR link as a
  comment on the linked ticket.

Full branch-naming and commit-format rules: see
[`references/git-rule.md`](references/git-rule.md).

## Branch guard (both params)

1. Run `git branch --show-current` to read the active branch.
2. If the branch is `main` or `master`: **stop**. Tell the user the protected
   branch rule and ask them to create a feature branch first.
3. Extract the ticket id from the branch name (pattern:
   `<type>/<ticket-id>-<description>`, e.g. `feature/123-add-login` → `123`).
   If no id can be parsed, ask the user for it before continuing.
4. Remind the user to link the branch to the ticket's Development section if
   not yet done (`gh issue develop <id> --name <branch>` or GitHub UI).

## cp — commit and push

1. Run `git status` and `git diff --cached --stat` to see what is staged.
   If nothing is staged and there are unstaged changes, ask whether to stage
   all or selectively.
2. Determine the commit type/scope from the change (reuse `bi-commit-convention`
   rules — check `git log --oneline -5` for the project's scope convention).
3. Build the commit message following `git-rule.md`: `type(scope): subject (#<ticket-id>)`.
   - Subject in imperative mood, ≤ 72 chars total.
   - Ticket id in subject is preferred. Footer-only (`Closes #<ticket-id>` or
     `Refs #<ticket-id>`) is also accepted when the subject is near the limit.
   - If the user supplied a message, verify it contains the ticket id in at
     least one accepted form; if not, inject `(#<ticket-id>)` or ask for
     confirmation.
4. Commit: `git commit -m "<message>"`.
5. Push: `git push origin <branch>` (use `--set-upstream` if the branch has
   no upstream yet).
6. Confirm: echo the pushed commit SHA and branch.

## pr — create pull request and comment on ticket

1. Run `git log <base>..<branch> --oneline` (default base: `main` or `master`,
   whichever exists) to summarise the changes on this branch.
2. Check for a PR template: look for `.github/pull_request_template.md` or
   `.github/PULL_REQUEST_TEMPLATE.md`. Use it if present.
3. Draft the PR description filling in at minimum:
   - **What**: one or two sentences on the change.
   - **Why**: the problem or requirement; include `Closes #<ticket-id>`.
   - **How**: non-obvious decisions or trade-offs.
   - **Testing**: how the change was verified.
4. Create the PR: `gh pr create --title "<type>(<scope>): <subject>" --body "<description>"`.
5. Capture the resulting PR URL.
6. Post a comment on the ticket:
   `gh issue comment <ticket-id> --body "PR opened: <PR URL>"`.
7. Confirm: echo the PR URL and the ticket comment link.

## Verification

- `git log -1 --format="%B"` confirms the full commit message (subject + body +
  footer) contains the ticket id in at least one accepted form.
- `gh pr view` confirms the PR exists with a non-empty description.
- `gh issue view <id> --comments` confirms the PR-link comment is present.

## Anti-patterns

- Do NOT commit or create a PR while on `main` or `master` — always refuse
  and redirect.
- Do NOT commit without the ticket id in the message — extract it from the
  branch name or ask; never skip it.
- Do NOT open a PR with an empty or title-only description — fill the template.
- Do NOT force-push (`git push --force`) during a normal `cp` — use
  `--force-with-lease` only when explicitly rebasing and only after confirming
  with the user.
- Do NOT silently ignore a missing ticket id in the branch name — ask.
