# Goals

## Mission

Give coding agents the frontend engineering judgment of a senior developer —
across **web and mobile, with React and React Native as the primary focus** —
packaged as installable, versioned, test-proven skills, built first for
Claude. The `bi-` prefix (short for Binh, the author) brands every plugin
and skill in the library.

## Who this serves

1. **Mobile/frontend developers using Claude Code** — the primary audience.
   They install a toolkit once and their agent stops making the classic
   mistakes (cache-nuke debugging, blind conflict resolution, cargo-cult
   memoization).
2. **Users of other Agent Skills-compatible tools** (Cursor, Codex, Copilot,
   Gemini CLI, ...) — served by keeping skill content pure standard, free of
   Claude-Code-only constructs.
3. **Contributors** — served by docs, templates, linters, and a TDD loop that
   make quality mechanical rather than tribal.

## What a skill must be

Every skill in this repo must satisfy all three:

1. **Behavior-changing** — proven by eval scenarios where the agent fails
   without the skill and passes with it. If baseline behavior is already
   correct, the skill does not earn its context cost and is rejected.
2. **Opinionated** — one default path plus an escape hatch, never a menu.
3. **Trigger-reliable** — the description contains the exact words, symptoms,
   and error strings users actually type.

## Scope

**In scope (current):** `bi-git`, `bi-react-native`,
`bi-android`, `bi-ios`, `bi-pencil` (agent-driven UI design
in [Pencil](https://pencil.dev) via its MCP tools, mobile-first — designs
live as `.pen` files in the repo and hand off to RN/SwiftUI/Compose code).

**Planned:** `bi-react` — React web skills (component architecture,
performance, debugging), completing the React + React Native core; further
frontend toolkits as demand appears.

**Naming convention:** marketplace `bi-skills`; every plugin and skill is
prefixed `bi-`. Rationale: personal brand visibility in session logs and
skill listings, zero collision risk with other installed marketplaces, and
a consistent identity when skills are copied standalone into other tools.

**Out of scope (non-goals):**

- Backend/infra skills — other marketplaces cover them; staying focused is
  the differentiator.
- MCP servers, hooks, agents, LSP configs — this repo ships knowledge
  (skills), not runtime integrations. Skills MAY teach the use of external
  MCP servers the user installs themselves (bi-pencil does), but we
  bundle none.
- An npm installer package of our own — distribution analysis (2026-07)
  showed marketplace + the generic `npx skills add` path covers all users
  without the security and staleness liabilities of a custom installer.
- Monetization — free and MIT-licensed; adoption and reputation first.

## Distribution goals

1. **Primary channel:** this repo as a self-hosted Claude Code plugin
   marketplace (`/plugin marketplace add ngocbinh123/claude-skill-v1`).
2. **Secondary channel:** acceptance into `anthropics/claude-plugins-community`
   once v0.x stabilizes — the repo is kept submission-ready at all times
   (validate-clean, per-plugin LICENSE/README, data-handling statement).
3. **Tertiary reach:** installable by non-Claude agents via
   `npx skills add ngocbinh123/claude-skill-v1`; listed on skills.sh for
   install analytics.

## Success metrics

- Every shipped skill has GREEN eval evidence recorded in `evals/`.
- CI is green on `main` at all times (`main` = the stable channel users track).
- Community-marketplace submission accepted without rework.
- External signals: installs (skills.sh), GitHub stars, issues from real users.
