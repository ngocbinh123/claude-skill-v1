# Theme Mapping Rules — token code → theme contract

MUI is the canonical target below; another framework keeps the SAME hash
header, module shape, and update semantics, with the field mapping defined
in the project's spec doc. Follow exactly; determinism matters (git diff is
the review surface).

## Hash header (change detection)

First lines of the theme module (first entry of `theme-files`):

```ts
// Built from design tokens by bi-pencil-token-to-theme — edit via the skill, not by hand.
// tokens-hash: <sha256 of design-tokens.json, lowercase hex>
```

Compute: `shasum -a 256 <tokens dir>/design-tokens.json`. Update the header
ONLY after all selected phases are GREEN. Missing header = treat as new
build (idempotent, safe).

## Module shape

```ts
import { createTheme, type Theme } from '@mui/material/styles';
import { colorTokens, type TokenBrand, type TokenMode } from './tokens/color-tokens';
// + typography-tokens, spacing-radii-tokens, shadow-tokens

export function getAppTheme(brand: TokenBrand = '<default>', mode: TokenMode = 'light'): Theme {
  const c = colorTokens[brand][mode];
  return createTheme({ palette: { mode, ... }, typography: { ... }, shape: { ... }, components: { ... } });
}
```

Rules:
- **Zero hex/px literals sourced from design** — every design value comes
  from a token import. Structural values the framework requires that have
  no token (e.g. MUI `contrastThreshold`) are allowed but must be commented.
- `palette.mode = mode` (MUI internals depend on it).
- Alpha-carrying hex8 tokens (`c-row-hover` etc.) pass through as-is — MUI
  accepts #RRGGBBAA.
- Line-height: MUI wants unitless or px string — use
  `` `${lineHeight}px` `` from the type scale.
- `as const` token types flow through; do not widen to `string`.

## Palette map (per theme combo)

| MUI | Token |
|-----|-------|
| `palette.primary.{main,dark,light,contrastText}` | `c-primary-{main,dark,light,contrast}` |
| `palette.secondary.*` | `c-secondary-*` |
| `palette.error/warning/info/success.main` | `c-{severity}-main` (+ dark/light/bg where present) |
| `palette.background.{default,paper}` | `c-bg-app`, `c-bg-paper` |
| `palette.text.{primary,secondary,disabled}` | `c-text-{primary,secondary,disabled}` |
| `palette.divider` | `c-border-default` |
| `palette.action.hover` | `c-row-hover` |

Token names differ per project → the actual `c-*` vocabulary comes from the
project's token files; this table is the default shape to mirror.

## Typography map (MD3 → MUI)

h1←headline-lg · h2←headline-md · h3←headline-sm · h4←title-lg ·
subtitle1←title-md · subtitle2←title-sm · body1←body-lg · body2←body-md ·
caption←body-sm · button←label-lg + `letterSpacing.button`px +
`textTransform:'none'` · overline←label-sm + `letterSpacing.overline`px.
Base `fontFamily` ← `fontFamilies.body` (+ system fallbacks).

## Shape / shadows / overrides

- `shape.borderRadius ←` the project's medium radius token (e.g. `r-md`).
- Component overrides reference shadow token strings and `c-*` values only.
- Keep the override set minimal (Button, Card, AppBar to start); grow only
  when the spec doc adds items.

## Update semantics

- Token diff → phase mapping: color tokens → item 1 (+3 if
  border/shadow-adjacent); typography/font/letter-spacing tokens → item 2;
  radii/shadows → item 3. Wiring (item 4) re-runs only if the theme module
  API changed.
- Surgical edits preserve structure; `--force` rewrites the module from
  this contract.
- Tests first, always: update expected values from the new tokens BEFORE
  editing the theme (RED → implement → GREEN). Never adjust a test to match
  wrong output.
