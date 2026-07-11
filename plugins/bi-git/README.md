# bi-git

Git workflow skills for Claude Code.

| Skill | Triggers on | Teaches |
|---|---|---|
| `bi-commit-convention` | committing, commit messages, changelog | Conventional Commits, splitting mixed diffs, breaking-change footers |
| `bi-rebase-conflict` | rebase, merge conflicts, lost commits | Intent-based conflict resolution, `--force-with-lease`, reflog recovery playbook |
| `bi-pr-workflow` | opening PRs, review feedback | PR sizing, self-review, description structure, review etiquette |
| `bi-git-create-ticket` | creating tickets, issues, sub-issues | Structured description template, metadata interview, parent linking |

## Install

```
/plugin marketplace add ngocbinh123/claude-skill-v1
/plugin install bi-git@bi-skills
```

## Data handling

Plain-markdown skills: no external calls, no data collection, nothing
executed at install time.
