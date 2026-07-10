# Theme Spec Template — seed for `theme-spec` doc

Copy into the target project (path from CLAUDE.md `theme-spec`) on first
run, adapt paths/token names, commit. Checkboxes are progress markers the
skill ticks after each GREEN phase; tests remain the source of truth.

```markdown
# Design Theme Spec — <app> (built by bi-pencil-token-to-theme)

Source tokens: <tokens dir> | Theme module: <theme-module path> | Issue: #<n>

## Spec items (one phase each; tests-first)

- [ ] 1. Palette map — `getAppTheme(<dims>)`; palette from `c-*`:
      primary/secondary/error/warning/info/success ← `c-{role}-{main|dark|light|contrast}`;
      `background.default ← c-bg-app`, `background.paper ← c-bg-paper`;
      `text.{primary|secondary|disabled} ← c-text-*`; `divider ← c-border-default`;
      `action.hover ← c-row-hover`. All theme combos constructible; default (<default combo>).
- [ ] 2. Typography map — MD3 typeScale → theme variants:
      h1←headline-lg, h2←headline-md, h3←headline-sm, h4←title-lg,
      subtitle1←title-md, subtitle2←title-sm, body1←body-lg, body2←body-md,
      caption←body-sm, button←label-lg + ls-button (textTransform none),
      overline←label-sm + ls-overline; fontFamily ← fontFamilies.body.
- [ ] 3. Shape, shadows, component overrides —
      `shape.borderRadius ← r-md`; Button (radius, no elevation, hover ← c-primary-dark);
      Card (shadow-card); AppBar (c-bg-paper, c-text-primary, border ← c-border-default).
- [ ] 4. Shim + wiring — <legacy theme file> re-exports getAppTheme(<default combo>)
      with @deprecated; app entry consumes getAppTheme.
- [ ] 5. Verify — full test suite + build green; visual check on the
      design-dashboard (dev); shell primary renders <expected primary hex>
      in the default combo.

## Test map

| Item | Test file / cases |
|------|-------------------|
| 1 | get-app-theme.test.ts: all combos construct; primary.main pins per brand; bg/text/divider mapped |
| 2 | variant sizes/weights/lineHeights match typeScale; button textTransform 'none' |
| 3 | shape.borderRadius = <r-md value>; overrides reference token values |
| 4 | legacy shim === getAppTheme(<default combo>) result shape; imports compile |
| 1-4 | lint-style: no `#hex` literal in theme module source |

## Notes / decisions

- Brand/theme-dim = init parameter only; no end-user brand UI.
- Non-MUI framework: define the field mapping here (this doc IS the
  mapping contract the phases implement).
- <project-specific notes>
```
