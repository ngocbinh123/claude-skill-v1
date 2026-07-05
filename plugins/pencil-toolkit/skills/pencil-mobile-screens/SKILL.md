---
name: pencil-mobile-screens
description: Design mobile app screens (iOS, Android, React Native) in Pencil with correct device frames, safe areas, touch targets, and theme-ready tokens, then hand off to code. Use when designing mobile UI or app screens in Pencil, or implementing a Pencil design as React Native, SwiftUI, or Compose components.
---

# Mobile Screens in Pencil

## Overview

Mobile screens designed with desktop habits produce broken apps: content
under the status bar, untappable buttons, one hardcoded theme. Set up the
platform constraints in the design so the generated code inherits them for
free. This skill extends `pencil-design` (opening sequence, tokens,
components) with mobile-specific rules.

## Frame setup

- One screen state = one device-sized frame, portrait by default:
  **390×844** (iOS baseline) or **360×800** (Android baseline). Never a
  desktop-width artboard for mobile work.
- Name frames `Screen/State`: `Home/Default`, `Home/Empty`,
  `WorkoutList/Loading`.
- Reserve safe areas as real layout spacers inside the frame:

| Zone | iOS | Android |
|---|---|---|
| Status bar | 59 (Dynamic Island) / 47 | 24–32dp |
| Bottom home indicator | 34 | gesture nav ~24dp |
| Tab bar / bottom nav (if any) | 49 + indicator | 56dp |
| Nav header | 44 | 56dp (app bar) |

## Mobile design rules

1. **Touch targets ≥ 44×44pt (iOS) / 48×48dp (Android)** — including hit
   area, not just the icon glyph. Space adjacent targets ≥ 8 apart.
2. **4/8 spacing grid.** All padding/gaps are multiples of 4; screen edge
   padding 16 by default.
3. **Theme axis from the start.** Light/dark variables before painting any
   fill — retrofitting dark mode onto hex-painted screens is rework.
4. **Type ramp for glanceable reading**: body ≥ 15–16, secondary 13,
   one screen title style. System-font metrics (SF / Roboto) unless the
   product ships a brand font.
5. **Thumb-zone layout.** Primary actions live in the bottom half; top
   corners are for navigation, not for the main CTA.
6. **Design the unhappy states.** Every list/data screen gets sibling
   frames for loading, empty, and error — the implementer will otherwise
   invent them.
7. **Rows and cards are components** with instance overrides for content —
   the code side becomes one component + props, matching the design.

## Handoff to mobile code (React Native / SwiftUI / Compose)

1. Read structure with `snapshot_layout` + `batch_get`; never implement
   from a screenshot alone (you'll copy pixel values instead of layout
   intent).
2. Auto-layout → flexbox (`flexDirection`, `gap`, `padding`); safe-area
   spacers → `SafeAreaView`/`safeAreaInsets`/`WindowInsets`, NOT the
   hardcoded pixel heights from the table above.
3. `get_variables` → the app's theme module (e.g. tokens object consumed by
   a `useTheme` hook). No resolved hex values in components.
4. `export_nodes` for raster assets at mobile densities (@1x/@2x/@3x or
   mdpi–xxxhdpi); prefer vector/code-drawn where possible.
5. Verify: run the app, screenshot it, compare against `get_screenshot` of
   the frame — spacing and hierarchy should match without measuring.

## Anti-patterns

- Do NOT put content in safe-area zones or size tap targets under platform
  minimums "because it looks tighter".
- Do NOT hardcode safe-area heights in code — they come from the platform
  APIs at runtime; the design values are for canvas layout only.
- Do NOT design only the happy path.
- Do NOT translate the design to code by reading pixel positions off a
  screenshot — use the layout tools.
