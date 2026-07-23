# cb — create branch

Turns a ticket id into a correctly-named, convention-checked working branch
BEFORE any code is written, so the later `cp` / `pr` steps inherit a branch
that already carries a traceable ticket id and a valid name.

`cb` only creates (and checks out) a branch. It never stages, commits, pushes
content, stashes a dirty tree, or rebases — those belong to `cp` / `pr` and
`bi-rebase-conflict`.

## 1. Resolve branch type, then the ticket id + prefix

First decide the branch type from the prompt: a **feature** branch requires a
ticket id (resolve it below); a **release** branch (`release/v{app-version}`,
step 4) carries no ticket — skip straight to version resolution and use a
no-ticket creation path (plain `git`, since `gh issue develop` needs an issue).

For a feature branch, read the ticket id from the prompt.

- Already prefixed (`CS-22`, `FC-123`) → use as-is.
- Bare number (`123`) → prepend the host repo's prefix from the per-repo
  table in `references/git-rules.md`:

  | Project | Prefix |
  |---|---|
  | Guard Admin | `GA` |
  | Guard App | `GA` |
  | FlowCalc | `FC` |
  | Guard platform | `GP` |
  | Claude skill v1 | `CS` |

Resolve *which project* from the repo declaration (a `docs/project-overview.md`
project/prefix statement, or the `origin` remote URL), NOT an interactive
prompt — unless it cannot be determined. If the host cannot be resolved to a
prefix, ASK the user for the prefix; never guess one.

> Traceability note: the prefixed id lives in the branch name only. GitHub's
> `Closes #<n>` (written later by `pr`) needs the numeric tail — `CS-22` → `#22`.
> See SKILL.md pre-flight step 3.

## 2. Base-branch guard (confirm, never auto-switch)

```bash
git branch --show-current
gh repo view --json defaultBranchRef --jq .defaultBranchRef.name  # discover the default
```

Resolve the repo's **actual** default branch (usually `main`/`master`, but it
may be `develop`/`trunk`) — that resolved value is the base and the `{destination}`
segment (step 4). If the current branch IS the default, branching off it is
fine — proceed. If it is anything else (`feature/old-thing`, `release/*`,
detached HEAD), STOP and confirm with the user before branching off it, and
offer branching from the default as an explicit option:

```text
Current branch is `feature/old-thing`, not the default (`master`).
  1) Branch from `feature/old-thing` (keep its commits)
  2) Branch from `master` (clean base)   ← usual choice
```

The guard only *confirms*. It never silently checks out `main` on the user's
behalf.

## 3. Tool detection (gh vs plain git)

```bash
git remote get-url origin        # is origin a github.com remote?
command -v gh                    # is gh installed?
```

- **GitHub remote AND `gh` present** → create via `gh` so the branch links to
  the ticket's Development section in one step:

  ```bash
  gh issue develop <numeric-id> --name "<branch-name>" --base "<base>" --checkout
  ```

  `--checkout` is required — without it `gh issue develop` creates the branch
  remotely but leaves the working tree on the old branch, so later `cp`/`pr`
  commands would run on the wrong branch.

- **Otherwise (no `gh`, or non-GitHub remote)** → plain git:

  ```bash
  git checkout -b "<branch-name>" "<base>"
  ```

  When the remote IS GitHub but the branch was made with plain `git` (no `gh`),
  tell the user to **link the branch to the ticket manually** in the ticket UI —
  no automatic link happened.

## 4. Branch-name build + validation

### Formats (see `references/git-rules.md`)

`cb` uses its OWN two formats below — NOT the generic `<type>/<issue>-<slug>`
default that `cp`/`pr` read from. Emit the name character-for-character as
specified; the common mistakes are dropping a required segment.

- **Feature:** `feature/{ticket-id}-{destination}-{short-title}`
  - Literal `feature/` prefix — never the short `feat/`.
  - `{ticket-id}` — prefixed id from step 1 (`CS-22`).
  - `{destination}` — REQUIRED even when it is the default branch; the branch
    this work merges into, defaulting to the repo's resolved default from step 2
    (`main`/`master`/other). Other destinations are ignored. Do NOT omit it:
    `feature/CS-22-master-add-cb-param`, not `feature/CS-22-add-cb-param`.
  - `{short-title}` — kebab-case slug of the ticket title, trimmed to a few
    words (`Add cb create-branch param` → `add-cb-create-branch-param`).
- **Release:** `release/v{app-version}` — the `v` is REQUIRED
  (`release/v1.6.0`, never `release/1.6.0`).
  - `{app-version}` — read from the project (`app.json` / `package.json`
    `version`) or from the prompt; never invented.

Example: ticket `CS-22` "Add cb param", destination `master` →
`feature/CS-22-master-add-cb-param`.

### User-supplied name

If the user supplies a branch name, validate it against the format above. If it
does not match (e.g. `my-branch` — no `feature/` type, no ticket id), do NOT
silently rename or create it. Reject it and offer corrected suggestions as an
**option list**, each carrying the ticket id:

```text
`my-branch` doesn't match `feature/{ticket-id}-{destination}-{short-title}`. Pick one:
  1) feature/CS-22-master-add-cb-param
  2) feature/CS-22-master-my-branch
```

## 5. Confirm, create, then ask about push

1. **Confirm before creating.** Show the final branch name and base, and wait
   for the user's go-ahead. Never create silently.
2. **Create** via the tool chosen in step 3.
3. **Ask whether to push** to the remote — do NOT auto-push:

   ```bash
   git push -u origin "<branch-name>"   # only after the user says yes
   ```

## Optional: per-repo specialized script

The steps above are the shipped default (the agent states the exact commands).
A repo that needs specialized branch logic MAY bundle a
`scripts/create-branch.sh` and the workflow will prefer it. Documented contract
(no executable is shipped by this skill yet — YAGNI, add when a repo needs it):

```text
create-branch.sh <ticket-id> <destination> [<short-title>]
  → resolves prefix, builds the name, runs the base guard + tool detection,
    prints the branch name it created; exit non-zero on validation failure.
```

## Output summary

```text
✓ ticket id: CS-22 (prefix resolved: Claude skill v1 → CS)
✓ base guard: on master — ok  |  confirmed branching off <branch>
✓ name: feature/CS-22-master-add-cb-param (validated)
✓ created via: gh issue develop --checkout  |  git checkout -b
✓ push: pushed origin/<branch>  |  skipped (user declined)  |  link ticket manually (no gh)
```

## Errors

| Error | Action |
|-------|--------|
| Prefix undetectable | Ask the user for the prefix; do not guess |
| User-supplied name invalid | Offer corrected suggestions as an option list; do not create |
| Branch already exists | Report it; ask whether to check it out instead of recreating |
| `gh issue develop` fails (403 / API) | Fall back to `git checkout -b`; tell the user to link the branch manually |
