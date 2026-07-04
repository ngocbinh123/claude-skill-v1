# claude-skill-v1

Claude Code plugin scaffold focused on helping developers work effectively through a consistent, minimal-change delivery workflow.

## Included skill

- `developer-workflow` — guides Claude through issue analysis, repo exploration, focused implementation, testing, validation, and handoff.

## Repository structure

```text
.claude-plugin/plugin.json
skills/developer-workflow/SKILL.md
```

## What the skill covers

- understanding the request before changing code
- exploring the repository and existing commands first
- making the smallest complete change
- adding or updating focused tests when test infrastructure exists
- validating code, checking for secrets, and summarizing results