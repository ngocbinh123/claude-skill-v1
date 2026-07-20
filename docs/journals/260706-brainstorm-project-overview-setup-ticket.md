# Brainstorm: Project overview declarations setup

**Date**: 2026-07-06 14:28
**Severity**: Medium
**Component**: Developer onboarding / agent knowledge
**Status**: Approved for execution

## What Happened

User came with solution, but we reframed to problem: every Claude session / skill re-asks invariant facts (board URL, design tool, architecture, git rules). No single source of truth. Agreed: need declarative file agents read on startup.

## The Brutal Truth

This is friction we should have eliminated months ago. Every new skill wastes cycles re-interviewing users for the same project metadata. Each skill holds partial, inconsistent copies.

## Technical Details

Chosen structure: `docs/project-overview.md` declares values + links native homes (.github/PULL_REQUEST_TEMPLATE.md, docs/design-token). CLAUDE.md links to overview. No content duplication — links only.

## Approaches Rejected

- All-in-one file: drifts against source of truth (DRY violation)
- Merge into CLAUDE.md: bloats agent config, mixes declarations with behavior instructions

## Root Cause Analysis

Treated each skill as isolated. Never enforced "project facts live here" convention. Reusable skill (`bi-project-overview`) was deferred because immediate need is ONE ticket, not a generator.

## Lessons Learned

1. Upfront declarative layer pays for itself in multi-session, multi-skill envs.
2. Interview-driven ticket (first Q: project type) beats pre-filling. Generic template reusable across projects.
3. DRY at scale: links not copies. Only scalars (URLs, names) live in overview.

## Next Steps

Run `binh-gh-create-ticket` with ticket body from brainstorm report against target repo. User supplies repo at execution time. If design guideline path missing, file follow-up ticket.

## Unresolved Questions

- Target repo not pinned — decided to ask user at ticket execution time
- Whether `docs/design-token` exists in target repo — will surface at first run
