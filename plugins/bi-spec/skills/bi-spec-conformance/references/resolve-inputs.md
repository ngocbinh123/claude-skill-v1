# Resolve inputs — spec + implementation

Two inputs must be resolved before any comparison: the **spec** and the
**implementation surface**.

## Spec resolution (order)

1. **User-provided path** — always preferred. Read it directly.
2. **Not provided → ASK.** Do not glob-and-guess. Ask one concrete question and
   offer the project convention as a hint:
   > "What's the spec path? (convention: `features/docs/{ticket-id}-{title}/`, e.g. `features/docs/GA-777-alarm-assign/spec.md`)"
3. **No spec file at all → paste fallback.** Let the user paste the requirement
   text; treat the pasted text as the spec source. Because there is no spec
   directory to write next to, you MUST also settle an **output location**: ask
   the user where to save the report (suggest the repo root or `docs/`), OR ask
   them to save the pasted spec to a file first and use that path. Record the
   source as `pasted (no file)` in the report header instead of a spec path.

Never proceed to classification until the spec **and** a report output location
are concretely resolved.

## Implementation resolution

The implementation surface is the **current branch's changes**, not the whole
codebase.

- **Default (committed branch work):**
  ```bash
  git branch --show-current            # confirm not on the default branch
  git diff <default-branch>...HEAD      # THREE-dot: branch's own changes since divergence
  ```
  Use the **three-dot** form — it diffs against the merge-base, so unrelated
  commits landed on the default branch after you diverged are excluded. The
  two-dot `<default-branch>..HEAD` is wrong here (tip-to-tip).
  Determine the default branch **locally** (no network):
  `git symbolic-ref --short refs/remotes/origin/HEAD` (strip the `origin/`), else
  fall back to `master`/`main`, else ask the user. Do NOT use `gh repo view` or
  `git remote show origin` — they hit the network and break the offline / no-
  external-calls guarantee.
- **Uncommitted work present:** the surface is the committed branch diff **plus**
  the working tree — do not drop either:
  ```bash
  git diff <default-branch>...HEAD      # committed branch changes
  git diff --staged                     # staged
  git diff                              # unstaged
  git status --short                    # untracked (read new files directly)
  ```
- **Do NOT** require a manual `git merge-base` step or a GitHub PR to exist.
  (The three-dot form already resolves the merge-base for you.)
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
