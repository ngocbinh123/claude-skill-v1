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

### `cb` branch formats (create-branch param)

The `cb` param (see `references/workflow-cb.md`) builds branches in these
formats — an alternate convention that coexists with `<type>/<issue>-<slug>`:

- **Feature:** `feature/{ticket-id}-{destination}-{short-title}` —
  e.g. `feature/CS-22-master-add-cb-param`
- **Release:** `release/v{app-version}` — e.g. `release/v1.6.0`
  (version read from `app.json` / `package.json`, or the prompt)

The `{ticket-id}` is prefixed (`CS-22`); its numeric tail (`22`) is what
GitHub's `Closes #<n>` uses. `{destination}` defaults to the repo default
branch (`main`/`master`); other destinations are ignored.

### Per-repo ticket-id prefix table

A bare ticket number is normalized to `PREFIX-<number>` using the host repo:

| Project | Prefix |
|---|---|
| Guard Admin | `GA` |
| Guard App | `GA` |
| FlowCalc | `FC` |
| Guard platform | `GP` |
| Claude skill v1 | `CS` |

Resolve the project from the repo declaration (`docs/project-overview.md` or
the `origin` remote), NOT an interactive prompt — unless it is undetectable,
in which case ask the user for the prefix rather than guessing.

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
