# Showcase & Design-Dashboard Template

Scaffold for Step 5. Mirrors the Pencil showcase frames (Colors x theme
dims, Typography, Scale, Shadows) as in-app pages. Examples use React +
react-router — adapt paths/router/framework to the target project.

## Principles

0. **Analyze the design library FIRST (Step 5.0)** — showcase structure
   comes from the actual `Showcase - *` frames
   (`snapshot_layout`/`get_screenshot`) and the icon guideline's real icon
   set/list, never invented from token values. Values stay data-driven from
   tokens; STRUCTURE and icon content mirror the design. Missing icon source
   in the app (design uses one icon set, app ships another) → ask, don't
   substitute silently.
1. **Data-driven only**: every showcase iterates the synced token objects.
   Hardcoding a token name/value in a showcase is a defect — it silently
   drifts.
2. **Dev-only**: gate route registration behind `import.meta.env.DEV` (or
   the project equivalent / config `rules` override). Showcases must not
   ship to production.
3. **One page per group + one dashboard**: dashboard is the single entry
   linking all showcase pages; add new group pages to the dashboard list
   when scaffolding them.

## Layout (example)

```
src/pages/design-dashboard/
  DesignDashboardPage.tsx      # links to all showcases + theme-dim switcher context
  ColorShowcasePage.tsx        # swatch grid per c-* token, all theme combos
  TypographyShowcasePage.tsx   # type specimen per style (size/weight/line-height)
  SpacingRadiiShowcasePage.tsx # spacing bars sp-*, radius boxes r-*
  IconLayoutShowcasePage.tsx   # ic-* sized boxes, layout-* dimension bars
  ShadowShowcasePage.tsx       # elevation cards per shadow token, light + dark
```

## Dashboard pattern

```tsx
// DesignDashboardPage.tsx — dev-only index of token showcases
const SHOWCASES = [
  { path: 'colors', label: 'Colors', page: <ColorShowcasePage /> },
  { path: 'typography', label: 'Typography', page: <TypographyShowcasePage /> },
  { path: 'spacing-radii', label: 'Spacing & Radii', page: <SpacingRadiiShowcasePage /> },
  { path: 'icon-layout', label: 'Icons & Layout', page: <IconLayoutShowcasePage /> },
  { path: 'shadows', label: 'Shadows', page: <ShadowShowcasePage /> },
];
// Render as nav list + <Routes>; wrap in a theme-dim selector so every
// showcase re-renders under the chosen combo (reuse dev theme switcher if present).
```

## Showcase pattern (colors example — iterate, never enumerate)

```tsx
// ColorShowcasePage.tsx
import { colorTokens } from '../../theme/tokens/generated/color-tokens';

export function ColorShowcasePage({ brand, mode }: ThemeCombo) {
  return (
    <Grid container spacing={1}>
      {Object.entries(colorTokens[brand][mode]).map(([name, hex]) => (
        <SwatchCard key={name} name={name} value={hex} />
      ))}
    </Grid>
  );
}
// SwatchCard: color square + token name + hex label. Group rows by prefix
// (c-primary-*, c-text-*, ...) derived from the name — still data-driven.
```

Same shape for other groups: typography renders a specimen line per style
(size from tokens, weight/line-height from supplemental map); spacing
renders bars sized by `sp-*`; shadows render cards with each shadow token
applied.

## Route registration (dev-only)

```tsx
// In the app router:
{import.meta.env.DEV && (
  <Route path="/design-dashboard/*" element={<DesignDashboardPage />} />
)}
```

## Icon showcase (structure from guideline, not placeholder)

- Icon set + icon list come from the project's icon guideline doc (e.g.
  `icon-system-guideline.md`: named set + named icons).
- Render the GUIDELINE'S icon list at each `ic-*` size — grouped as the
  Pencil icon showcase groups them. One sample icon repeated across sizes =
  defect.
- Icon source strategy is a user decision captured once (font link / SVG
  package / approximation) and recorded in CLAUDE.md `rules`.

## Sync behavior

- Missing page for a group in scope → scaffold it and add to the dashboard
  list.
- Group removed from design → ask before deleting its page (mirror of
  token-removal confirmation).
- Value-only changes → no showcase edits needed (data-driven); just verify
  compile via `verify-command`.
