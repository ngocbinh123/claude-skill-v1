# Baseline & evidence — bi-spec-conformance

Runner: `node tools/run-evals.js --plugin bi-spec --skill bi-spec-conformance`
(advice mode; use `--ablation` for the runner-backed no-skill arm).

## 2026-08-05 — RED evidence (manual, pre-SKILL.md)

The automated runner skips eval dirs without a SKILL.md, so this baseline was
recorded manually with the runner's exact no-skill invocation
(`claude -p "<prompt>" --tools ''`) per scenario. The recording machine has
global git/dev guidance in `~/.claude/`, so this baseline is *stricter* than a
clean environment — failures below survive even that head start.

Per-scenario failure modes without the skill:

- **S1** — Proceeds on a guessed spec path (globs `features/docs/*` or assumes a
  filename) instead of asking; or asks a vague "where is the spec?" without
  offering the `features/docs/{ticket-id}-{title}/` convention.
- **S2** — Compares against `HEAD~1` or the working tree ad hoc, or reaches for a
  merge-base / requires a PR; does not settle on branch-vs-default `git diff` with
  a working-tree fallback.
- **S3** — Assumes the task-history requirement is "probably handled elsewhere"
  and does not emit a `missing` verdict with a search-proof; no grep scope stated.
- **S4** — Notes the `>=` vs "more than" mismatch loosely but rarely produces a
  concrete failing example (exactly 200m) or a precise operator fix.
- **S5** — Tends to flag the AsyncStorage choice as a problem to fix, rather than
  classifying it as an intentional `different` needing intent-confirmation only.
- **S6** — Defaults to reviewing/confirming one item at a time or dumps all items
  without a per-item verdict mechanism; no batch confirm.
- **S7** — Given "FIX everything", a no-skill agent edits source files directly
  instead of producing a report-only artifact and handing off.
- **S8** — Produces an ad-hoc summary with no fixed report location, no per-verdict
  counts, no confidence column, inconsistent structure.
- **S9** — Declares the code "wrong/buggy" and proposes editing the code, missing
  that this is a spec ⇄ code contradiction where the spec was the wrong side;
  does not offer a two-way fix.
- **S10** — Either hard-asserts the guard is broken or ignores it; does not gate
  by confidence and route a runtime-dependent claim to a user question.
- **S11** — Focuses on the new schema shape and overlooks old-version backward
  compatibility; does not emit a `missing` migration verdict with a search-proof.
- **S12** — Reproduces the reviewer's false-positive: reports the universal-link
  scheme as missing from `Info.plist` without a whole-repo grep that would find
  it in `GuardApp.entitlements`.

Conclusion: all 12 scenarios fail or behave generically without the skill. The
sharpest gaps (real value of the skill) are S1 (ask-not-guess), S3/S11 (missing +
search-proof), S7 (report-only, no mutation), S9 (contradiction + two-way fix),
and S12 (2-round grep avoids false-positive).

## GREEN evidence

### 2026-08-05 — static gates (SKILL.md authored)

- `node tools/lint-frontmatter.js` → OK (13 skills pass; frontmatter is exactly
  `name` + `description`, description contains "Use when …").
- `node tools/check-governance.js` → OK (bi-spec ships README/LICENSE/CHANGELOG;
  scenarios.md has `**Prompt:**` + `- [ ]`; SKILL.md present).
- `node tools/sync-versions.js --check` → marketplace.json in sync (bi-spec 0.1.0).
- `node tools/run-evals.js --plugin bi-spec --dry-run` → all 12 scenarios parsed
  (S1–S8 4 behaviors each, S9 5, S10–S12 4).
- SKILL.md body = 113 lines (≤ 500; depth pushed to 4 references/).

### Behavioral GREEN (2026-08-06, CI `run-evals.js --plugin bi-spec`)

First CI run: 11/12 pass; **S8 (report shape) failed** — the runner injects only
SKILL.md (not references), so the report structure that lived only in
`report-template.md` was invisible to the graded agent. It omitted the rough-%,
the confidence column, and the unresolved-questions section.

Fix: inlined the required report skeleton into SKILL.md §4 (header, summary with
counts + rough %, findings table with the exact columns incl. Confidence,
hand-off note, unresolved-questions). Re-run S8 with-skill → **4/4 pass**.

All 12 scenarios GREEN (S1–S12). Lesson: anything a scenario grades must be
answerable from SKILL.md alone — references are not injected into the eval arm.
