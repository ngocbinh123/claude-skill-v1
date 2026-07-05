# pencil-toolkit

Skills for designing UI in [Pencil](https://pencil.dev) — the agent-driven
design canvas — through its MCP tools, with a mobile-first focus that pairs
with this marketplace's React Native / Android / iOS toolkits.

| Skill | Triggers on | Teaches |
|---|---|---|
| `pencil-design` | designing UI in Pencil, .pen files, mockups | The opening sequence (state → guidelines → components → variables), tokens-first and components-first design, screenshot verification, design-to-code handoff |
| `pencil-mobile-screens` | mobile/app screens in Pencil, implementing Pencil designs in RN/SwiftUI/Compose | Device frames, safe areas, touch targets, theme axes, state variants, layout-tool-based (not screenshot-based) handoff |

## Prerequisites

Pencil's MCP server ships **inside** the Pencil desktop app / VS Code /
Cursor extension — there is nothing to install from npm. Install Pencil
from [pencil.dev](https://pencil.dev), then enable your agent under
**Settings → Agents & MCP**; Pencil writes the MCP configuration for you.
Verify with `/mcp` (a `pencil` server should show as connected).

## Install

```
/plugin marketplace add ngocbinh123/claude-skill-v1
/plugin install pencil-toolkit@ngocbinh-skills
```

## Data handling

Plain-markdown skills: no external calls, no data collection, nothing
executed at install time. The skills drive the Pencil MCP server that YOU
installed and configured; this plugin bundles no MCP server of its own.
