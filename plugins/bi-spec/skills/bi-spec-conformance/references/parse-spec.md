# Parse the spec into checkable requirements

The taxonomy classifies **one requirement at a time**, so the spec must first be
split into discrete, checkable checkpoints.

## Best-effort extraction

Pull a requirement from each of these:

- **Headings / numbered sections** describing a behavior.
- **Bullets** that state a rule (especially imperative ones).
- **Normative sentences** — those containing `must`, `must not`, `should`,
  `shall`, `does not`, `never`, `always`, `only`, `required`, `owned by`,
  `responsible for`. These are the highest-signal requirements; each becomes an
  assertion.
- **Tables / examples** that fix concrete values, inputs→outputs, or edge cases
  (e.g. "exactly 200m → allowed"). Turn each row into a checkpoint.

Normalize each into a one-line **assertion**: `<subject> <must/must-not> <do X>`
or `<input> → <expected output/state>`. Attach the source line number — you need
it for the evidence quote later.

## Split partial requirements

A single spec bullet can carry several checkpoints ("implement full or a part").
Split a compound requirement so each sub-part can carry its own verdict — one
sub-part can be `correct` while a sibling is `missing`.

## Fallback: ask the user (free-form specs)

When the spec is prose-heavy, ambiguous, or has no clear normative structure,
do NOT invent requirements. Extract a best-effort checklist, then **show it to
the user and ask them to confirm/edit** before comparing:

> "Here are the {N} requirements I extracted from the spec. Confirm or edit this
> list before I compare it to the code."

This keeps verdicts anchored to a requirement set the user agrees with, and is
the safety valve against hallucinated requirements.

## Do not

- Do not treat rationale/explanation prose as a requirement unless it states a
  rule. (Rationale is useful later, for two-way `incorrect` fixes.)
- Do not merge unrelated rules into one checkpoint — it muddies the verdict.
