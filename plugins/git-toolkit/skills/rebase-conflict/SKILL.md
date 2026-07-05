---
name: rebase-conflict
description: Safely rebase branches and resolve merge/rebase conflicts, and recover from mistakes with reflog. Use when rebasing, resolving merge conflicts, when git reports conflicted files, or when the user lost commits or wants to undo a git operation.
---

# Rebase & Conflict Resolution

## Overview

Conflicts are resolved by understanding BOTH sides' intent, never by picking a
side blindly. Every step below is recoverable — **nothing is lost until
`git reflog` expires**, so prefer stopping and inspecting over guessing.

## Before any rebase

1. Ensure a clean tree: `git status`. Stash or commit first — never rebase
   with uncommitted changes.
2. Know your escape hatch: note the current SHA (`git rev-parse HEAD`).
   `git rebase --abort` returns here at any point.
3. Fetch the real target: `git fetch origin` then rebase onto
   `origin/<branch>`, not a stale local copy.
4. NEVER rebase a branch other people are building on top of, unless the team
   has agreed. Rewriting shared history forces everyone downstream to recover.

## Resolving conflicts (per file)

1. See the full picture first: `git status` for the conflicted list, and
   `git log --oneline --left-right HEAD...MERGE_HEAD` (merge) or the rebase
   progress output to understand which commits collide.
2. For each conflicted file, read the WHOLE file, not just the markers.
   Understand what `ours` and `theirs` were each trying to do:
   - During **rebase**, sides are inverted vs merge: `ours` = the branch you
     are rebasing ONTO; `theirs` = your own commits being replayed.
3. Resolve by combining intents. If both sides changed the same logic for
   different reasons, the correct resolution usually includes both changes —
   not one side.
4. If the intent of the other side is unclear, find its commit:
   `git log --oneline -3 -- <file>` and read the message/diff before deciding.
5. Remove ALL conflict markers, then `git add <file>`.
6. Continue: `git rebase --continue` (or `git merge --continue`). Repeat.
7. After completion, build and run tests BEFORE pushing — a textually clean
   resolution can still be semantically wrong.

## Force-pushing after rebase

Only ever use `git push --force-with-lease` — plain `--force` can silently
destroy teammates' commits pushed after your last fetch.

## Recovery playbook

| Situation | Fix |
|---|---|
| Mid-rebase, want out | `git rebase --abort` |
| Rebase finished but result is wrong | `git reflog`, find the pre-rebase SHA, `git reset --hard <sha>` |
| Deleted a branch with unmerged work | `git reflog` still has its tip: `git branch restore <sha>` |
| Committed to the wrong branch | `git branch keep && git reset --hard origin/<branch>` then cherry-pick onto the right one |
| Resolved a conflict wrongly, already continued | `git reflog` back, or fix forward with a new commit if already pushed |
| Same conflicts repeating across a long rebase | Enable `git config rerere.enabled true` (records resolutions, replays them) |

## Anti-patterns

- Do NOT resolve by accepting one whole side (`--ours`/`--theirs`) unless you
  have verified the other side's change is genuinely obsolete.
- Do NOT `git push --force` to "make the error go away" — diagnose first.
- Do NOT continue a rebase while tests are failing "to fix later"; fixing at
  the conflicting commit is cheaper than untangling afterwards.
- Do NOT delete and re-clone the repo to escape a bad state — the recovery
  playbook above is faster and preserves work.
