# Dual-Agent Setup — Claude Code + Cursor

This SKILL.md (plus these references) is the single source of truth for the
workflow. Both agents load the SAME files; nothing is duplicated.

## Prerequisite (both agents): Pencil MCP

The sync workflow calls Pencil MCP tools (`get_editor_state`,
`get_variables`, `snapshot_layout`, `get_screenshot`). Install the Pencil
app / IDE extension and enable the agent's MCP connection (Pencil: Settings
→ Agents & MCP). Without the MCP connected, the skill must stop and say so —
never hand-edit `.pen` files as a workaround.

## Claude Code

```
/plugin marketplace add ngocbinh123/claude-skill-v1
/plugin install bi-pencil@bi-skills
```

The skill triggers from its description ("sync design token", "pencil to
code", "token drift check") or explicitly via
`/bi-pencil-token-to-code <sync|check>`.

## Cursor

Skills follow the open Agent Skills standard; install with any
SKILL.md-compatible installer:

```
npx skills add ngocbinh123/claude-skill-v1
```

Or wire manually — create `.cursor/rules/bi-pencil-token-to-code.mdc` in the
target project pointing at the skill files:

```markdown
---
description: Sync design tokens from a Pencil .pen design system into code token files. Apply when the user asks to sync/check design tokens from Pencil.
---

Follow the workflow in <path-to>/bi-pencil-token-to-code/SKILL.md exactly,
including its references/ docs. Project config comes from the
"## Design Token Sync" section of this project's CLAUDE.md (the config
section name is shared regardless of agent).
```

An `AGENTS.md` entry pointing at the same SKILL.md works too. Configure the
Pencil MCP server in Cursor (Settings → MCP) with the same server the
Pencil app exposes.

## Per-project config (agent-independent)

Both agents read the target project's `CLAUDE.md` section
`## Design Token Sync` (see `claude-md-config-template.md`). Keep that file
as the single per-project config surface even when running from Cursor.
