---
name: bi-spec-conformance
description: Compare a branch's implementation against its spec and classify each requirement as correct, incorrect, missing, or different, then write a conformance report with suggested fixes (never edits code). Use when the spec does not match the implementation, when reviewing code against a spec or ticket, or when the user says "spec vs code", "compare spec implementation", "check implementation against spec", "find missing spec", "spec diff", or "spec conformance".
---

# bi-spec conformance (spec ⇄ implementation)

## Overview

Compare a **spec** against the **implementation on the current branch** and
report where they diverge. Each spec requirement gets one verdict — ✅ correct,
⚠️ incorrect, ❌ missing, 🔀 different — backed by cited evidence. The user
confirms every mismatch before it lands in the report. **This skill never edits
code**: it writes a report and hands off to `/cook` or `/fix`.

Core principle: a mismatch is a **contradiction between spec and code**, not
proof the code is wrong. Either side can be the stale one — the user decides.

## Workflow

1. **Resolve inputs** → spec + implementation surface. See
   `references/resolve-inputs.md`.
2. **Parse the spec** into discrete, checkable requirements. See
   `references/parse-spec.md`.
3. **Classify each requirement** against the code using the taxonomy + evidence
   rules. See `references/diff-taxonomy.md`.
4. **Batch-confirm** mismatches with the user (below).
5. **Write the report** next to the spec. See `references/report-template.md`.
6. **Hand off** — recommend `/cook` or `/fix` with the report; do not implement.

## 1. Resolve inputs (summary)

- **Spec:** use the path the user provides. If none is given, **ASK** — offer
  the convention `features/docs/{ticket-id}-{title}/` as a hint. Never glob a
  guess and proceed silently. Fallback: let the user paste the requirement text.
- **Implementation:** the branch's changes. Default `git diff <default-branch>...HEAD`
  (e.g. `git diff master...HEAD`); if there are uncommitted changes, use the
  working-tree diff instead. No manual `git merge-base` step, no PR required. Read the
  changed files for context, not only the raw hunks. Escape hatch: `--files <paths>`.

Full rules: `references/resolve-inputs.md`.

## 2. Classify (summary)

Split the spec into requirements, then give each ONE verdict:

| Verdict | Meaning |
|---------|---------|
| ✅ correct | Code implements the requirement and matches it |
| ⚠️ incorrect | Code implements it but **contradicts** the spec |
| ❌ missing | No code implements it (proven by a 2-round grep) |
| 🔀 different | Code does something else / beside the spec (often intentional) |

Detection axes (most-common first, from real reviews): **side-effect/guard**,
contract, value, condition, branch, **migration/config**. Evidence rules and
worked examples: `references/diff-taxonomy.md`.

Two non-negotiable rules:

- **Evidence required.** No finding without `spec-quote` + `file:line` + a
  **failing example** — or, for `missing`, a **search-proof** (terms grepped +
  scope). No citation ⇒ not a finding.
- **2-round grep for `missing`.** Search the diff AND the whole repo before
  asserting absence. Code may live where the spec didn't name it.

Confidence gating: a static contradiction is `high` → assert. A runtime-dependent
claim is `low` → present it as a question, do not hard-assert.

## 3. Batch-confirm mismatches

Present the mismatch list and confirm with the user in **batches**, not one
prompt per item. Use `AskUserQuestion` with `multiSelect` so the user marks
several at once; each item still carries a per-item verdict: **real** (keep) /
**skip** (drop) / **discuss** (needs a decision). Only user-confirmed items go
into the report. `correct` items are summarised, not individually confirmed.

## 4. Report + hand-off

Write `<spec-dir>/conformance-report-{YYMMDD}.md` (always next to the spec).
Structure and columns: `references/report-template.md`. For `incorrect`, the
suggested fix is **two-way** (align code OR update spec) when the spec carries a
rationale that could be stale. `different` items get no fix — intent-confirm
only. End by recommending `/cook` or `/fix` with the report path.

## Verification

Before finishing, confirm:
- [ ] Spec resolved from a real path (asked if it was missing).
- [ ] Implementation surface came from the branch/working-tree `git diff`.
- [ ] Every reported finding has spec-quote + `file:line` + failing example (or
      search-proof for `missing`).
- [ ] Every `missing` verdict ran the 2-round grep.
- [ ] Every mismatch in the report was user-confirmed.
- [ ] No source file was edited; report written next to the spec; hand-off stated.

## Anti-patterns

- **Do NOT** guess/glob a spec path when the user gave none — ASK.
- **Do NOT** edit code, commit, or push — report + suggested fix only.
- **Do NOT** report a finding without spec-quote + `file:line` + failing example
  (search-proof for `missing`).
- **Do NOT** assert `missing` from the diff alone — run the 2-round grep first;
  code may live where the spec didn't name it.
- **Do NOT** call `incorrect` "a code bug" — it is a spec ⇄ code contradiction;
  the spec may be the wrong side. Offer a two-way fix.
- **Do NOT** hard-assert runtime-dependent findings — gate by confidence; `low`
  → ask the user.
- **Do NOT** propose a fix for `different` — surface it for intent-confirmation.
- **Do NOT** drift into general code-quality review (style/perf/security) — stay
  in the spec-conformance lane.
- **Do NOT** confirm mismatches one prompt at a time — batch them; and never
  write an unconfirmed mismatch into the report.
- **Do NOT** invent requirements the spec does not state.
