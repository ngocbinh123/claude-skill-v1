# Diff taxonomy — classify each requirement

For every parsed requirement R, assign exactly one verdict, backed by evidence.

## The decision

Ask, in order:

1. **Does the code try to satisfy R?**
   - No code touches R → run the 2-round grep. Still nothing → ❌ **missing**.
   - Code does something *else* / *beside* R **and R is still satisfied by that
     alternative** (different approach, requirement met) → 🔀 **different**. If
     the adjacent code does NOT actually satisfy R, do not call it `different` —
     fall through to the 2-round grep and treat as ❌ `missing` (or ⚠️
     `incorrect` if it attempts R but contradicts it).
2. **It does try — does the result match the spec?**
   - Matches → ✅ **correct**.
   - Contradicts the spec → ⚠️ **incorrect**.

`missing` = absence. `incorrect` = present but contradictory. `different` =
present but divergent-in-intent. `correct` = present and matching.

## Detection axes (most-common first)

Check R against the code on these axes; the first real contradiction decides.

1. **Side-effect / behavioral-guard** — the spec forbids or requires an action,
   a write, or a guard. Check for the presence/absence of the forbidden/required
   operation in the *named scope*. (Most common axis in real reviews.)
2. **Contract** — type, field name, function signature, enum value, HTTP status,
   request/response schema.
3. **Value** — constant, default, sort direction, threshold number.
4. **Condition** — operator, boundary, inverted logic (`<` vs `<=`, negation).
5. **Branch** — a case the spec lists that the code doesn't handle or mishandles.
6. **Migration / backward-compat / config-manifest** — schema-version handling
   for existing users, platform declarations (manifest/plist/entitlements),
   feature-flag gating. (Dominant `missing` flavor.)

## Evidence rules (non-negotiable, verdict-specific)

Every finding needs the **spec quote** + a **`file:line`** (or dash for
`missing`). The third piece depends on the verdict:

- **`incorrect`** → a **failing example**: a concrete input where
  spec-expected ≠ code-actual (the way a failing test would show it).
- **`missing`** → a **search-proof**: the exact terms you grepped and the scope
  (diff + whole repo).
- **`different`** → **equivalence evidence**: show the requirement is still
  satisfied by the alternative (there is no "failing example" — nothing failed).
- **`correct`** → the matching code location; no failing example needed.

**No citation ⇒ not a finding.** If you cannot quote the spec and point to a
line (or prove absence for `missing`), drop it — do not report a hunch.

## `missing` requires a 2-round grep

Before asserting R is absent:

1. **Round 1 — diff:** is R implemented in the branch changes?
2. **Round 2 — whole repo:** grep the whole repo for R's symbols, keywords, and
   synonyms (function names, routes, fields, config keys, alternate file types
   like `.entitlements`).

Only if BOTH rounds find nothing is it `missing`. This prevents the classic
false-positive of "not in the file I expected ⇒ missing".

## Confidence gating

- **high** — a static contradiction (name, type, constant, operator, a present
  forbidden side-effect, a proven absence). Assert it.
- **low** — correctness depends on runtime behavior you can only infer (call
  ordering, timing, a guard that "should" hold). Do NOT hard-assert — present it
  to the user as a verification question.

## `incorrect` is a contradiction, not a code-bug

When spec and code disagree, you do NOT know which side is stale. Present both
sides neutrally ("spec says X at L#; code does ¬X at file:line") and, when the
spec carries a rationale that might itself be outdated, offer a **two-way fix**:
align the code to the spec, OR update the spec to match the code. The user is
the oracle for direction.

## `different` gets no fix

A `different` verdict means the code met the requirement a different way, often
deliberately. Surface it for **intent-confirmation** only — do not propose a fix.

## Worked examples (real reviews)

- **Side-effect, `incorrect`, spec was wrong (GA-814):** spec L161 "the token
  getter does **not** write storage"; code `FirebaseService.ts:340` calls
  `saveFCMTokenToStorage(live)` inside `getFirebaseToken`. Verdict ⚠️ incorrect,
  confidence high, two-way fix. (Resolution in real life: the spec was updated.)
- **Guard, `incorrect`, low confidence (GA-806):** docs require a
  "once-per-launch guard" for `isRetryEnable`; `retry-milestone-manager.ts:70`
  may not enforce it statically. Verdict ⚠️ incorrect, confidence low → ask.
- **Migration, `missing` (GA-806):** `received-report-store.ts:34` changes the
  stored `ReceivedReportRecord` schema; grep for `migrat`/`version`/old-shape
  handling across the repo finds none. Verdict ❌ missing, search-proof cited.
- **Negative / anti-hallucinate (GA-694):** universal-link scheme suspected
  missing from `Info.plist`; whole-repo grep finds it in
  `GuardApp.entitlements`. Verdict ✅ correct — NOT missing.
- **Different, intentional (alarm counters):** spec wants instant paint on cold
  start; code uses `AsyncStorage` (a UI-only cache) instead of the non-persisted
  Redux store. Verdict 🔀 different, no fix, intent-confirm.
