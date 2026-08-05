# Resolve inputs — spec + implementation

Two inputs must be resolved before any comparison: the **spec** and the
**implementation surface**.

## Spec resolution (order)

1. **User-provided path** — always preferred. Read it directly.
2. **Not provided → ASK.** Do not glob-and-guess. Ask one concrete question and
   offer the project convention as a hint:
   > "What's the spec path? (convention: `features/docs/{ticket-id}-{title}/`, e.g. `features/docs/GA-777-alarm-assign/spec.md`)"
3. **No spec file at all → paste fallback.** Let the user paste the requirement
   text; treat the pasted text as the spec source.

Never proceed to classification until the spec is concretely resolved.

## Implementation resolution

The implementation surface is the **current branch's changes**, not the whole
codebase.

- **Default (committed branch work):**
  ```bash
  git branch --show-current            # confirm not on the default branch
  git diff <default-branch>...HEAD      # e.g. git diff master...HEAD
  ```
  Determine the default branch from the repo (`git remote show origin` /
  `gh repo view --json defaultBranchRef`), default to `master`/`main`.
- **Uncommitted work present:** use the working tree instead —
  `git status --short` then `git diff` (and `git diff --staged`).
- **Do NOT** require a manual `git merge-base` step or a GitHub PR to exist.
  (The three-dot `A...HEAD` already resolves the merge-base for you — that is the
  point; you just don't compute it by hand or gate on a PR.)
- **Read the changed files**, not only the raw hunks — a hunk rarely shows
  enough surrounding scope to judge a requirement.

### Escape hatch: `--files <paths>`

When ticket→diff is not usable (no branch, spec covers pre-existing code the
branch didn't touch), let the user name the files/dirs to inspect and treat
those as the implementation surface. State that coverage is user-scoped.

## Whole-repo access is still required

Even though the implementation *surface* is the diff, you MUST be able to grep
the **whole repo** — the 2-round grep for `missing` (see `diff-taxonomy.md`)
depends on it. A requirement can be satisfied by code outside the diff.
