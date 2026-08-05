# Changelog — bi-spec

## 0.1.0 — 2026-08-05

- `bi-spec-conformance`: new skill. Compares a branch's implementation against
  its spec and classifies each requirement as correct / incorrect / missing /
  different. Resolves the spec from a user-provided path (asks when missing,
  hinting `features/docs/{ticket-id}-{title}/`); resolves the implementation
  from the branch `git diff` (vs default branch, working-tree fallback). Detects
  mismatches across side-effect/guard, contract, value, condition, branch, and
  migration/config axes; requires spec-quote + `file:line` + a failing example
  (or a search-proof for `missing`, via a mandatory 2-round grep). Frames
  `incorrect` as a spec ⇄ code contradiction with a two-way fix (align code or
  update spec). Batch-confirms findings with the user, then writes a
  conformance report next to the spec. Never edits code — hands off to
  `/cook` or `/fix`.
