---
name: bi-commit-convention
description: Write commit messages following Conventional Commits. Use when creating git commits, writing commit messages, splitting changes into commits, or when the user mentions commit style, commit lint, or changelog generation.
---

# Commit Convention

## Overview

Every commit message follows Conventional Commits so history is readable and
changelogs/semver bumps can be automated. **One commit = one logical change.**

## Message format

```
<type>(<scope>): <subject>

[optional body]

[optional footer]
```

### Types

| Type | Use for | Semver |
|---|---|---|
| `feat` | New user-facing behavior | minor |
| `fix` | Bug fix in existing behavior | patch |
| `refactor` | Code change, same behavior | — |
| `perf` | Performance improvement, same behavior | patch |
| `docs` | Documentation only | — |
| `test` | Add/fix tests only | — |
| `build` | Build system, dependencies | — |
| `ci` | CI configuration | — |
| `chore` | Maintenance that fits nothing above | — |

Breaking change: append `!` after type/scope (`feat(api)!: ...`) and add a
`BREAKING CHANGE:` footer explaining the migration.

### Subject rules

- Imperative mood: "add", not "added" or "adds"
- Lowercase after the colon, no trailing period
- Max ~72 characters; if you can't fit, the commit is probably doing too much
- Say WHAT changed at a level useful to a reader scanning `git log --oneline`

### Body rules

- Explain WHY, not how — the diff already shows how
- Wrap at 72 characters
- Reference issues in the footer: `Closes #123`, `Refs #456`

## Workflow when committing

1. Run `git status` and `git diff` (staged and unstaged) — never commit blind.
2. Group changes into logical commits. If the diff mixes a bugfix with a
   refactor, split it: stage selectively with `git add -p` or by file.
3. Determine `type` from the dominant intent of each commit, not the file type.
4. Pick `scope` from the project's existing convention — check
   `git log --oneline -20` first and mirror what the repo already uses.
5. Write the message, applying the subject rules explicitly: imperative
   mood, ≤72 characters, no trailing period. If a body is needed, explain
   the reason for the change.
6. Verify nothing unintended is staged (`git diff --cached --stat`).

## Examples

Good:

```
feat(auth): add refresh-token rotation

Access tokens expired after 15 minutes and users were logged out
mid-session. Rotate refresh tokens on every renewal so sessions
survive as long as the app is in active use.

Closes #482
```

```
fix(cart): prevent double submit on checkout button
```

Bad → good:

| Bad | Why | Good |
|---|---|---|
| `update code` | Says nothing | `refactor(parser): extract token scanner` |
| `Fixed bug` | Not imperative, no context | `fix(upload): handle files over 2GB` |
| `feat: fix crash and add dark mode and cleanup` | Three changes in one | Three separate commits |
| `WIP` | Never commit WIP to a shared branch | Squash before pushing |

## Anti-patterns

- Do NOT bundle unrelated changes to "save commits" — small commits are cheap,
  tangled history is expensive.
- Do NOT write messages describing the code ("change x to y") when the reader
  needs the intent ("prevent y from racing with z").
- Do NOT invent a scope taxonomy — reuse the repo's existing scopes.
- If the project has commitlint/husky configured, run it locally before
  pushing rather than discovering failures in CI.
