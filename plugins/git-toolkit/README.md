# git-toolkit

Git workflow skills for Claude Code.

| Skill | Triggers on | Teaches |
|---|---|---|
| `commit-convention` | committing, commit messages, changelog | Conventional Commits, splitting mixed diffs, breaking-change footers |
| `rebase-conflict` | rebase, merge conflicts, lost commits | Intent-based conflict resolution, `--force-with-lease`, reflog recovery playbook |
| `pr-workflow` | opening PRs, review feedback | PR sizing, self-review, description structure, review etiquette |

## Install

```
/plugin marketplace add ngocbinh123/claude-skill-v1
/plugin install git-toolkit@ngocbinh-skills
```

## Data handling

Plain-markdown skills: no external calls, no data collection, nothing
executed at install time.
