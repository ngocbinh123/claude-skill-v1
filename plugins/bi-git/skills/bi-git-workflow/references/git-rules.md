# Bundled default git rules

These are the DEFAULTS the workflow applies when the host project declares no
git rules of its own. When the host declares rules (see SKILL.md pre-flight
step 2), the host's conventions replace the conventions below — the safety
floor in SKILL.md is never replaced.

## Branch naming

Format: `<type>/<issue>-<slug>` — e.g. `feat/6-bi-git-workflow`,
`fix/21-login-timeout`.

| Type | Purpose |
|------|---------|
| `feat` | New feature |
| `fix` | Bug fix |
| `refactor` | Restructure without behavior change |
| `docs` | Documentation only |
| `test` | Tests |
| `chore` | Maintenance, deps, config |
| `perf` | Performance |
| `hotfix` | Production fix |

The `<issue>` segment is the ticket number — it is where the workflow reads
the ticket id from, so a branch without it breaks traceability.

## Commit messages — Conventional Commits

```
type(scope): subject (#<issue>)
```

- Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`,
  `perf`, `build`, `ci`.
- Subject: imperative mood ("add", not "added"), ≤72 chars, no trailing
  period, describes WHAT changed.
- Ticket id: every commit message contains the ticket reference
  (`(#6)` suffix or in the body) so the change is traceable to its ticket.
- Scope optional but recommended; mirror scopes already used in `git log`.

### No AI references — ever

Never include in commit messages, PR titles, or PR bodies:

- "Generated with Claude" / "Generated with <any tool>"
- `Co-Authored-By: Claude <...>` or any AI co-author trailer
- Emoji robots or tool watermarks

## Split-commit criteria

Split into multiple commits when the staged changes mix:

- different types (feat + docs, code + config)
- different scopes (auth + payments)
- dependency/lockfile changes + code changes
- more than 10 unrelated files

Keep a single commit when everything is one type, one scope, one intent.
Each split commit still carries the ticket id.

## Push rules

- Always `git push -u origin <branch>` so the upstream is set.
- Never force-push. If a rewrite is truly needed, that requires the user's
  explicit per-instance confirmation — a project doc cannot pre-authorize it.
- Never push directly to the default branch.
