---
name: pencil-design
description: Design UI on the Pencil (pencil.dev) canvas through its MCP tools - screens, components, and design tokens in .pen files. Use when designing UI in Pencil, when the user mentions .pen files or the Pencil canvas, or when asked to mock up screens before implementing them.
---

# Designing in Pencil

## Overview

Pencil is an agent-driven design canvas: you design by calling its MCP tools
against a `.pen` file (JSON, lives in the repo), and verify results
**visually** with screenshots — the JSON tells you structure, never whether
it looks right. Design with the document's existing system (components,
variables, guidelines), not from a blank imagination.

## Step 0 — Verify the connection

Pencil's MCP server is bundled with its desktop app / IDE extension. If no
`pencil` MCP tools are available in the session:

1. Tell the user to install Pencil (desktop app or VS Code/Cursor extension
   from pencil.dev) and enable this agent under **Settings → Agents & MCP**
   inside Pencil — Pencil writes the MCP config itself.
2. Do NOT hand-edit `.pen` JSON as a workaround unless the user explicitly
   asks; without the running editor you cannot render or verify anything.

## Step 1 — Opening sequence (always, before any write)

```
get_editor_state({ include_schema: true })   # document tree + .pen schema
get_guidelines(...)                          # official design guides/styles
batch_get({ patterns: [{ reusable: true }] })# existing component inventory
get_variables()                              # design tokens + theme axes
```

Skipping this produces designs that fight the document's existing system —
the most common failure mode.

## Step 2 — Design

Write with `batch_design` ops: `Insert`, `Update`, `Delete`, `Move`, `Copy`,
`Replace`, `SetVariables`, `Generate` (AI/stock images), `FindEmptySpace`.

Rules, in priority order:

1. **Tokens first.** Bind every color/spacing to a variable (`$name`); if
   the value has no variable yet, add one via `SetVariables` (careful: it
   merges by overwriting the keys you pass). Define a light/dark theme axis
   BEFORE painting, not after.
2. **Components first.** Reuse `reusable: true` nodes as `ref` instances
   with overrides. Anything repeated (cards, rows, buttons) becomes a
   component + instances, never sibling copies.
3. **Structure.** Everything lives inside named frames with auto-layout —
   loose canvas elements and default names (`Frame 4`) produce garbage
   generated code. Names are semantic PascalCase (`PrimaryActionButton`)
   because they flow into code.
4. **Placement.** Call `FindEmptySpace` before inserting new top-level
   frames; never overlap existing work.
5. **Batch.** Group related ops in one `batch_design` call instead of many
   single-op calls — context cost scales per call.

## Step 3 — Verify visually

After each meaningful change: `get_screenshot` on the affected frame, look
at it, and fix what you see (spacing, contrast, alignment, overflow).
A design pass is not done until the screenshot looks right — for BOTH theme
modes if the document has a theme axis.

## Step 4 — Handoff to code

- Structure: `snapshot_layout` (computed bounds) + `batch_get` — implement
  auto-layout as flex containers.
- Tokens: `get_variables` → map 1:1 into the codebase's theme/token module;
  never copy resolved hex values into code.
- Assets: `export_nodes` (PNG/JPEG/WEBP/PDF) for images the code needs.
- Commit the `.pen` file with the code it produced — it is a source file.

## Anti-patterns

- Do NOT design before running the opening sequence.
- Do NOT hardcode hex values on nodes when a variable exists or belongs.
- Do NOT declare a design finished from JSON structure alone — screenshot
  or it didn't happen.
- Do NOT scatter elements outside frames or keep default node names.
- Do NOT duplicate what should be a component instance.
