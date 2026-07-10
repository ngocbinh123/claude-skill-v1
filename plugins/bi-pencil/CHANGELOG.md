# Changelog — bi-pencil

## 0.2.0 — 2026-07-10

- New skill `bi-pencil-token-to-code`: one-way design-token sync from a
  Pencil `.pen` design system into code token files — CLAUDE.md-driven
  config, Pencil editor guard with auto-open, `$ref` resolution with
  consumer-tier filtering, built-in TDD gate, data-driven showcase pages.
  Generalized from a project-specific predecessor.
- New skill `bi-pencil-token-to-theme`: build/update the app theme from
  generated token code — tokens-hash change detection, spec-driven phases
  (tests-first with resume), zero-hex guard. No Pencil MCP, CI-safe.
  Generalized from a project-specific predecessor.
- Both skills document dual-agent setup (Claude Code + Cursor) in
  `references/dual-agent-setup.md`.

## 0.1.0 — 2026-07-05

- Initial release with two skills: `bi-pencil-design` (core MCP design
  workflow), `bi-pencil-mobile-screens` (mobile-first frames, safe areas,
  touch targets, handoff to RN/SwiftUI/Compose).
