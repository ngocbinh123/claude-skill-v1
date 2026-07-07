# Git Rules

Reference for `bi-git-workflow`. All rules here are authoritative; the
SKILL.md dispatches to this file for detail.

## Branch naming

```
<type>/<ticket-id>-<short-description>
```

| Segment | Rules |
|---|---|
| `type` | `feature`, `fix`, `chore`, `docs`, `release` |
| `ticket-id` | The numeric GitHub issue id, no leading zeros |
| `short-description` | Kebab-case, 2–5 words, imperative ("add-login" not "added-login") |

Examples:
- `feature/123-add-login`
- `fix/456-cart-double-submit`
- `chore/789-update-dependencies`

**Protected branches: `main` and `master` — never commit or push directly,
never open a PR from these.**

## Commit message format

Follows Conventional Commits (`bi-commit-convention` skill):

```
<type>(<scope>): <subject> (#<ticket-id>)

[optional body]

[optional footer]
Closes #<ticket-id>
```

### Mandatory: ticket id in every commit

Every commit on a feature branch MUST reference the ticket id. Accepted forms:

- Inline in subject: `feat(auth): add refresh token (#123)`
- Footer only: `Closes #123` or `Refs #123`

At least one form is required. Prefer inline in the subject for visibility in
`git log --oneline`.

### Types and scopes

Reuse `bi-commit-convention` type table. Scope mirrors the repo's existing
convention — check `git log --oneline -10` first.

## Ticket — Development section

After creating and pushing a feature branch, the branch must be linked to the
ticket in GitHub's Development section (issue sidebar:
"Create a branch for this issue or link a pull request").

This is a manual step in the GitHub UI or via `gh issue develop <number> --name <branch>`.

## PR template

Check `.github/pull_request_template.md` (or `.github/PULL_REQUEST_TEMPLATE.md`)
for the project's PR template. Fill it in completely. At minimum the PR
description must include:

- **What**: one or two sentences describing the change
- **Why**: the problem or requirement; link the issue (`Closes #<id>`)
- **How**: non-obvious decisions and trade-offs
- **Testing**: how the change was verified

## PR → ticket link comment

After opening a PR, post a comment on the linked ticket:

```
PR opened: <PR URL>
```

This closes the loop so stakeholders watching the ticket see the PR without
searching.
