# bi-git

Git workflow skills for Claude Code.

| Skill | Triggers on | Teaches |
|---|---|---|
| `bi-commit-convention` | committing, commit messages, changelog | Conventional Commits, splitting mixed diffs, breaking-change footers |
| `bi-rebase-conflict` | rebase, merge conflicts, lost commits | Intent-based conflict resolution, `--force-with-lease`, reflog recovery playbook |
| `bi-pr-workflow` | opening PRs, review feedback | PR sizing, self-review, description structure, review etiquette |
| `bi-git-workflow` | "cp", "pr", commit and push, ship this, create a pull request | End-to-end cp/pr pipeline: branch guard, layered secret scan, ticket id in commits, remote-diff PRs, PR link commented on the ticket |

## Install

```
/plugin marketplace add ngocbinh123/claude-skill-v1
/plugin install bi-git@bi-skills
```

## Data handling

Plain-markdown skills: no external calls, no data collection, nothing
executed at install time.
