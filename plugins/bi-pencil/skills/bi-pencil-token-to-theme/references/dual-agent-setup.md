# Dual-Agent Setup — Claude Code + Cursor

This SKILL.md (plus these references) is the single source of truth for the
workflow. Both agents load the SAME files; nothing is duplicated.

No MCP prerequisite: this skill reads token CODE only (never Pencil MCP),
so it runs anywhere the repo is checked out — including CI/headless.

## Claude Code

```
/plugin marketplace add ngocbinh123/claude-skill-v1
/plugin install bi-pencil@bi-skills
```

Triggers from its description ("build theme", "token to theme", "rebuild
theme from tokens") or explicitly via `/bi-pencil-token-to-theme <build|verify>`.

## Cursor

Install with any SKILL.md-compatible installer:

```
npx skills add ngocbinh123/claude-skill-v1
```

Or wire manually — create `.cursor/rules/bi-pencil-token-to-theme.mdc` in
the target project:

```markdown
---
description: Build or update the app theme from generated design-token code. Apply when the user asks to build/rebuild/verify the theme from tokens.
---

Follow the workflow in <path-to>/bi-pencil-token-to-theme/SKILL.md exactly,
including its references/ docs. Project config comes from the
"## Design Token Sync" section of this project's CLAUDE.md
(keys theme-spec, theme-files).
```

An `AGENTS.md` entry pointing at the same SKILL.md works too.

## Per-project config (agent-independent)

Both agents read the target project's `CLAUDE.md` section
`## Design Token Sync` (see `claude-md-theme-config.md`). Keep that file as
the single per-project config surface even when running from Cursor.
