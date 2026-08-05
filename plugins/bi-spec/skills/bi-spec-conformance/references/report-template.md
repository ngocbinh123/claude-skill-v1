# Report template

Write the report into the **spec file's own directory**, named
`conformance-report-{YYMMDD}.md` — e.g. `features/docs/GA-777-alarm-assign/conformance-report-260805.md`.
This holds regardless of where the spec lives; do not use a fixed reports dir.
(When the spec was pasted with no file, use the output location agreed during
input resolution and set the source header to `pasted (no file)`.)

**Same-day overwrite guard:** the `{YYMMDD}` name is deterministic per day. Before
writing, check whether the target already exists — if so, ask the user whether to
overwrite it or append a collision-safe suffix (e.g. `-2`), so a prior report with
confirmed findings is never silently replaced.

Only **user-confirmed** mismatches appear in the findings table. `correct`
requirements are summarised in the counts, not listed individually.

## Structure

```markdown
# Conformance report — {spec title / ticket id}

- Spec: `{spec path}`  (or `pasted (no file)` when the spec was pasted)
- Implementation: `{diff command used}` on branch `{branch}`
- Date: {YYYY-MM-DD}

## Summary

- Requirements checked: {N}
- ✅ correct: {n}  ⚠️ incorrect: {n}  ❌ missing: {n}  🔀 different: {n}
- Implemented: ~{percent}% of spec requirements

## Findings

| # | Verdict | Requirement (spec quote + line) | Code (`file:line`) | Confidence | Suggested fix |
|---|---------|--------------------------------|--------------------|------------|---------------|
| 1 | ⚠️ incorrect | "…" (L161) | `FirebaseService.ts:340` | high | **Align code:** stop writing storage in the getter · **or update spec:** if the write is now required, revise L161 |
| 2 | ❌ missing | "…" (L12) | — (grepped `taskHistory`,`audit` repo-wide: 0) | high | Implement history recording on assign |
| 3 | 🔀 different | "…" (L8) | `alarm-counter-cache.ts:1` | — | (intent-confirm only, no fix) |

## Hand-off

This report does not change code. To implement the fixes, run:
`/cook {this-report-path}`  (or `/fix` for isolated corrections).

## Unresolved questions

- {list any items marked "discuss" during confirmation, or "None"}
```

## Column rules

- **Verdict** — one of ✅/⚠️/❌/🔀.
- **Requirement** — a short spec quote plus its line number.
- **Code** — `file:line`; for `missing`, put a dash and the search-proof
  (terms grepped + scope) in the same cell or a footnote.
- **Confidence** — `high` / `low` (blank for `different`).
- **Suggested fix**:
  - `incorrect` → **two-way** when the spec carries a rationale that may be
    stale (align code OR update spec); one-way when the spec is clearly right.
  - `missing` → one-way (implement it).
  - `different` → none (intent-confirm only).
