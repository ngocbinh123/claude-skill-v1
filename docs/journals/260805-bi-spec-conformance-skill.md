# bi-spec-conformance skill

**Date:** 2026-08-05 · **Branch:** feature/bi-spec-conformance-skill · **Commit:** 14fc677 (not pushed)

## What

New `bi-spec` plugin + `bi-spec-conformance` skill. Compares a spec against a
branch's implementation; classifies each requirement correct/incorrect/missing/
different with cited evidence; batch-confirms with the user; writes a
conformance report next to the spec. Never edits code — hands off to `/cook`/`/fix`.

Flow: brainstorm → plan (`--tdd`) → validate → cook. 4 TDD phases (RED scenarios
→ scaffold → GREEN SKILL+references → verify gates). 638 LOC, 13 files.

## Key decisions

- Implementation surface = branch `git diff <default>...HEAD` (working-tree
  fallback); no manual merge-base, no PR dependency.
- Spec path is user-provided; skill ASKS when missing (never globs a guess).
- Report written into the spec's own directory; batch/multiSelect confirm.
- Scope: report + suggested fix only, no auto-fix.

## Lessons (grounded in real guard-app PR review comments)

- **`incorrect` is a spec ⇄ code contradiction, not "code is buggy"** — either
  side can be stale. #822/GA-814: reviewer flagged code writing storage vs spec
  L161; the **spec** was the wrong side and got updated. → report offers a
  two-way fix (align code OR update spec).
- **2-round grep (diff + whole repo) is mandatory for `missing`** — #695/GA-694:
  universal-link scheme looked missing in `Info.plist` but lived in
  `.entitlements`. Diff-only lookup reproduces the human reviewer's false-positive.
- **side-effect/behavioral-guard is the most common mismatch axis** (#822, #808),
  ahead of contract/value.
- **migration/backward-compat is the dominant `missing` flavor** (#808 schema).
- Evidence-required (spec-quote + file:line + failing example / search-proof) +
  confidence gating (runtime-dependent → ask, don't assert).

## Verification

lint-frontmatter · check-governance · sync-versions --check all green; eval
dry-run parsed 12/12 scenarios; code-reviewer clean (3 nits fixed).

## Update — 2026-08-06 (behavioral eval + PR review)

- Behavioral eval ran in CI: 11/12, then **12/12 GREEN** after inlining the
  report skeleton into SKILL.md §4 (S8 failed because the runner injects only
  SKILL.md, not references — the report shape lived only in report-template.md).
- Addressed PR bot review (Copilot + CodeRabbit): three-dot diff enforced,
  local default-branch lookup (no `gh`), verdict-specific evidence, pasted-spec
  output location, same-day overwrite guard, README fence language.

## Unresolved

- S10/S11 use reviewer comments as proxy spec; pull real GA-806 docs for exact
  spec-quotes if stricter grounding wanted.
