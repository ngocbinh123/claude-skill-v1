# Clarify: CS-3 — Setup project overview declarations (docs/project-overview.md)

**Ticket**: [CS-3](https://github.com/ngocbinh123/claude-skill-v1/issues/3)
**Date**: 2026-07-06

## Context

**Who**: Binh (repo owner) and every Claude/agent session working in this repo — plus helper skills (ticket creation, spec writing, PR workflow) that need project facts.
**What they want**: Ask "where is the board / what commit rule / what architecture" once, and have every future session answer instantly without re-asking.
**Where**: Repo docs — a new `docs/project-overview.md`, linked from `CLAUDE.md`.
**Trigger**: Every new working session today starts with zero knowledge of the board URL and conventions; answers drift between sessions.

## User Journey

### Without This Feature (current)

1. Binh opens a new Claude session and asks it to create a ticket
2. Session doesn't know which board or label conventions to use
3. ❌ Session asks Binh the same questions it asked last week
4. ❌ Different sessions produce inconsistent tickets/PRs

### Expected Behavior

1. Binh opens a new Claude session and asks it to create a ticket
2. Session reads `CLAUDE.md` → follows link to `docs/project-overview.md`
3. ✅ Board URL, git rules, architecture answered from the file — no questions
4. ✅ Every session produces consistent output

## What It Should Do

- Interview Binh once (project type first; design section only if the project is mobile/web)
- Write `docs/project-overview.md` (~60 lines): declared values + links to each rule's home — never copy rule content in (avoid drift)
- Add one link line near the top of `CLAUDE.md` pointing to the overview
- Create `.github/PULL_REQUEST_TEMPLATE.md` (confirmed missing) and link to it [inferred: minimal template matching bi-pr-workflow skill guidance]
- If a declared path doesn't exist (e.g. design guideline), record a TODO and file a follow-up ticket instead of writing content

## How We Know It's Done

- [ ] Fresh session answers "where is the board / what commit convention" with no user prompt
- [ ] Ticket/PR skills read board URL + git rules from the overview
- [ ] No rule text duplicated between overview and its source file (links only)
- [ ] `CLAUDE.md` contains the link line; PR template exists in `.github/`

## What Needs Design?

No UI changes — documentation-only task.

## Questions for Stakeholders

| # | Question | Ask Who | If No Answer, We'll Assume |
|---|----------|---------|---------------------------|
| 1 | Ticket is filed on `claude-skill-v1`, but the example values (Clean Architecture, SOLID, Pencil, `docs/design-token`) describe an app project, not this markdown skills library. Is THIS repo the real target, or is it a template ticket to run on another repo (e.g. guard-app)? | Binh (PO) | This repo is the target; interview answers will use this repo's real values (5-layer plugin architecture, TDD evals), the app-style values are just examples |
| 2 | Does board `github.com/users/ngocbinh123/projects/2` actually track this repo's work? | Binh (PO) | Yes — declare it as-is |
| 3 | This repo's `CLAUDE.md` already declares architecture + git rules (via `docs/architecture.md`, `docs/governance.md`). Should the overview only ADD the missing facts (board, ticket conventions, PR template) and link to existing docs for the rest? | Binh (PO) | Yes — overview links to existing docs; no restatement |
| 4 | Skip the Design section for this repo (no UI, no Pencil file)? | Binh (PO) | Skip; note "N/A — documentation library" |

---

## Appendix: Technical Details

> For developers only. Stakeholders can skip this section.

### Affected Files

| Area | File | Impact |
|------|------|--------|
| Docs | `docs/project-overview.md` (new) | H |
| Agent context | `CLAUDE.md` (add 1 link line) | M |
| Git rules | `.github/PULL_REQUEST_TEMPLATE.md` (new — `.github/` currently has only `workflows/`) | M |

### Existing sources the overview should link to (no duplication)

| Fact | Native home |
|------|-------------|
| Architecture (5-layer plugin) | `CLAUDE.md` + `docs/architecture.md` |
| Governance / quality gates | `docs/governance.md` |
| Versioning / release | `docs/versioning.md` |
| Commit/PR conventions | bi-git skills (`plugins/bi-git/skills/*`) |
| CI gates | `.github/workflows/validate.yml`, `skill-evals.yml` |

### Verified facts (checked 2026-07-06)

- `.github/` contains only `workflows/` → PR template must be created
- `docs/design-token` does NOT exist in this repo → Design section N/A or TODO
- Repo tooling: `node tools/lint-frontmatter.js && node tools/check-governance.js && node tools/sync-versions.js --check`

### Fix Approach

Single doc pass: interview → write overview → patch CLAUDE.md → add PR template. No code. Estimated < 1h once Q1 is answered.

---

## Suggested Ticket Description

> Copy this section to update the GitHub ticket.

### Description

Every new Claude session in this repo re-asks invariant facts (board URL, ticket conventions, git rules). Create `docs/project-overview.md` as the single declarative source, linked from `CLAUDE.md`.

### Expected Behavior

A fresh session answers "where is the board / what commit convention / what architecture" from the repo docs with zero questions, and ticket/PR helper skills consume the same values.

### Acceptance Criteria

- [ ] `docs/project-overview.md` exists: declared values + links to native rule homes (no copied rule text)
- [ ] `CLAUDE.md` links to the overview near the top
- [ ] `.github/PULL_REQUEST_TEMPLATE.md` created and linked
- [ ] Fresh session answers board/git/architecture questions without prompting the user

### Scope

- **In**: overview file, CLAUDE.md link line, PR template, interview to capture values
- **Out**: design guideline content, GitHub branch-protection config, reusable generator skill (`bi-project-overview` — backlog)
