# Transform Rules — Pencil variables → code token files

Contract for Step 3 of the sync workflow. Follow exactly; determinism across
runs matters (git diff is the review surface).

## Input shape (get_variables)

```json
{
  "themes": { "brand": ["alpha", "beta"], "mode": ["light", "dark"] },
  "variables": {
    "p-red-main": { "type": "color", "value": "#FF5252" },
    "a-primary-main": { "type": "color", "value": [
      { "theme": { "mode": "light" }, "value": "$p-red-main" },
      { "theme": { "mode": "dark" },  "value": "$p-red-d-main" } ] },
    "c-primary-main": { "type": "color", "value": [
      { "theme": { "brand": "alpha" }, "value": "$a-primary-main" },
      { "theme": { "brand": "beta" },  "value": "$b-primary-main" } ] }
  }
}
```

Value forms: scalar (string/number/hex) | `$ref` string | array of
`{theme, value}` entries keyed on ONE dimension each. Dimensions cascade:
a brand-dim token may point to a mode-dim token.

## Reference resolution

For each consumer token x each combination of theme dims (e.g. brand x mode):

1. Pick the entry matching the current dim value (token themed on `brand` →
   pick by brand; single scalar → use as-is).
2. If value starts with `$` → strip `$`, look up that variable, recurse with
   the SAME dim context (so `$a-primary-main` then resolves by `mode`).
3. Terminal value must be concrete (hex6/hex8 for colors, number, string).
4. Errors — abort the token, collect, report all at end:
   - **Dangling**: `$name` not in variables.
   - **Circular**: revisiting a name within one chain (track visited set).
   - **Unresolvable dim**: themed array has no entry for the current dim value.
   - **Non-concrete terminal**: chain ends in another themed array with no
     matching dim.
5. NEVER emit a partial/guessed value. One bad token fails that token
   loudly, not silently.

## Tier filter

Export only the consumer tier named in config `rules` (e.g. `c-*`, plus
non-color scalar groups the project declares: `t-*`, `font-*`, `ls-*`,
`sp-*`, `r-*`, `ic-*`, `layout-*`, `logo-*`). Primitive and semantic tier
names must not appear in emitted code — they are resolution intermediates.

## Composites from guideline docs

Shadows (box-shadow strings), em-based letter-spacing, per-style
weight/line-height pairs are not Pencil variables. Read them from
`token-guideline` docs each run. If a doc value contradicts a design
variable (e.g. doc says font A, design says font B) → flag in report,
prefer the design variable, do not silently pick.

## Output style (TS targets)

- One export per logical group (colors, typography, spacing/radii,
  icon/layout, shadows) matching the project's existing token file layout;
  keys sorted alphabetically within each object.
- Color export shape: `colorTokens[<dim1>][<dim2>]['c-...'] = '#HEX'` — all
  combos present, identical key sets.
- Header on fully-generated files:
  `// DO NOT EDIT — synced from <pen-file> by bi-pencil-token-to-code`
- `as const` on token objects; no runtime logic inside token files.
- Non-TS targets: same rules in the project's language conventions.
- Surgical `sync` (non-force): edit exact value strings; preserve
  surrounding structure/comments. `--force`: rewrite whole file from this
  contract.

## design-tokens.json (audit artifact)

Committed verbatim snapshot (pretty-printed 2-space). Its git diff answers
"what changed in design"; do not reformat beyond pretty-printing, do not
filter tiers here (filtering happens at code emission).
