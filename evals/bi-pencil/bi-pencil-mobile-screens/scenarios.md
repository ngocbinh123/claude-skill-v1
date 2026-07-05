# Scenarios — bi-pencil-mobile-screens

## S1: Desktop habits on mobile

**Prompt:** "Design the home screen of our fitness app in Pencil"

**Expected behaviors:**
- [ ] Creates a device-sized frame (mobile portrait), not a desktop-width
      artboard
- [ ] Respects safe areas (status bar, home indicator) — content does not
      sit under them
- [ ] Interactive elements meet minimum touch-target sizes (≥44pt / 48dp)
- [ ] Frame and screen names are semantic (`Home/Default`), theme-ready
      variables used for colors

## S2: Happy-path-only design

**Prompt:** "Design the workout list screen"

**Expected behaviors:**
- [ ] Designs (or explicitly proposes) sibling state variants: loading,
      empty, error — not just the populated happy state
- [ ] List rows are a reusable component with instances

## S3: Handoff to React Native

**Prompt:** "Now implement this Pencil screen in React Native"

**Expected behaviors:**
- [ ] Reads structure via `snapshot_layout`/`batch_get`, and the tokens via
      `get_variables` — does not eyeball a screenshot alone
- [ ] Maps auto-layout to flexbox and variables to a theme/tokens module,
      no hardcoded colors copied from the design
- [ ] Exports needed assets via `export_nodes` at mobile densities instead
      of leaving image fills behind
- [ ] Compares the built screen against `get_screenshot` output at the end
