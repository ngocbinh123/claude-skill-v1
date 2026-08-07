# Review dimensions, severity, and evidence

Assess the diff correctness-first. Every finding must carry `file:line` **and** a
concrete failure scenario (inputs/state → wrong output/crash). No evidence ⇒ not
a finding.

## Dimensions (in priority order)

1. **Correctness** — logic bugs, null/undefined deref, off-by-one, inverted or
   wrong conditions, wrong branch taken, incorrect return value, type coercion
   surprises, async/await misuse, race conditions.
2. **Regressions** — changed public contract (signature, return shape, status
   code) without updating callers; a removed validation/guard; behavior a
   previously-passing test depended on.
3. **Security** — string-built SQL/shell/HTML from unvalidated input; missing
   auth / permission / ownership check; secret or token committed; unsafe deserialization; path traversal; overly-broad CORS.
4. **Error handling** — swallowed exceptions (`catch {}`), unhandled promise
   rejections, missing null/empty/timeout paths, resource leaks (unclosed
   handles), partial-failure states.
5. **Tests** — new or changed behavior shipped with no matching test; a test
   weakened or deleted to make the diff pass.
6. **Scope** — unrelated drive-by refactor/format churn mixed into the change;
   raises review cost and regression risk. Surface it; suggest a split. This is
   advisory — do NOT hard-block (that gate is `bi-pr-workflow`'s job).
7. **Readability** — only when it genuinely blocks a reviewer from understanding
   correctness. Never a blocker; personal style/naming preference is not a
   finding — defer to the linter/formatter.

## Severity tiers

| Tier | Meaning | Examples |
|------|---------|----------|
| 🔴 blocker | Will break in production or is exploitable | injection, data loss, crash on common input, auth bypass |
| 🟠 high | Likely bug or missing critical handling | unhandled error on a real path, regression for existing callers |
| 🟡 medium | Real but bounded / edge-case | missing edge case, weak test, risky-but-guarded code |
| 🟢 low | Minor / optional | naming, small readability, non-blocking suggestion |

Rank findings most-severe first. A clean diff legitimately yields "no blocking
issues" — say so; do not manufacture 🟡/🟢 items to look thorough.

## Confidence gating

- **Static contradiction** (you can point at the exact broken line and trace the
  failure) → assert the finding.
- **Runtime-dependent** ("this could deadlock if two requests race on X") where
  you cannot prove it from the diff → present as an **open question** in the
  report, not a hard-asserted finding.

## Worked examples

**🔴 correctness + security**

> `api/users.js:41` — query built as
> `` `SELECT * FROM users WHERE name='${req.query.name}'` ``.
> Failure: `name=' OR '1'='1` returns every row / enables injection.
> Fix direction: parameterized query / prepared statement.

**🟠 regression**

> `services/cart.ts:88` — `getTotal()` now returns cents (was dollars) but
> `checkout.ts:12` still divides by 100 twice. Failure: any checkout shows the
> total 100× too small. Fix direction: update the caller or keep the unit.

**🟡 error handling**

> `sync.js:23` — `await fetchAll()` has no catch; a network 500 rejects and
> aborts the whole sync mid-write. Failure: partial data on transient error.
> Fix direction: wrap + continue/rollback.

**Not a finding (drop it)**

> "This function is a bit long / I'd name it differently." No failure scenario,
> pure preference → linter/formatter or omit.
