---
name: bi-rn-performance
description: Diagnose and fix React Native performance problems - slow lists, dropped frames, re-render storms, slow startup, memory growth. Use when a React Native app is slow, laggy, janky, has low FPS, slow FlatList scrolling, or high memory usage.
---

# React Native Performance

## Overview

Measure BEFORE optimizing: every fix below starts from a profile, not a
guess. The two frame budgets: JS thread and UI thread each get ~16ms/frame.
Identify WHICH thread drops frames first (Perf Monitor in the dev menu),
because the fixes are disjoint.

- **JS thread janky, UI fine** → too much JS work per frame: re-renders,
  heavy computation, bridge-crossing in loops.
- **UI thread janky** → heavy native work: oversized images, deep view
  hierarchies, shadow/opacity abuse, non-native-driver animations.

## Playbook by symptom

### Slow list scrolling

1. Confirm the list is virtualized (`FlatList`/`FlashList`/`SectionList`),
   never `ScrollView` + `.map()` for >20 items.
2. Make `renderItem` cheap and stable:
   - Extract to a component wrapped in `React.memo`.
   - Stable `keyExtractor` (ids, never array index for mutable lists).
   - No inline closures/objects created per render passed to items.
3. Tune virtualization: `getItemLayout` for fixed-height rows,
   `windowSize`/`maxToRenderPerBatch`/`initialNumToRender` down from defaults
   for heavy rows; `removeClippedSubviews` on Android.
4. Fix images inside rows: request/display at rendered size, cache
   (`expo-image`/`FastImage`), no full-resolution photos in 80px cells.
5. If rows are still heavy, consider FlashList (recycling) after steps 1–4 —
   it amplifies, not replaces, correct item design.

### Re-render storms

1. Profile with React DevTools Profiler — find components rendering without
   visual change and the prop that caused it ("why did this render").
2. Standard fixes in order of impact:
   - Move state DOWN to the smallest component that needs it.
   - Split contexts: a context whose value changes per keystroke must not
     also carry stable values consumed app-wide.
   - `useMemo`/`useCallback` for referentially unstable props crossing memo
     boundaries; `React.memo` on expensive leaf components.
   - Selector-style subscriptions (zustand/redux `useSelector` with narrow
     selectors) instead of consuming whole stores.

### Animations

- Use `react-native-reanimated` worklets or `useNativeDriver: true` — the
  animation must not cross the bridge per frame.
- Animate `transform`/`opacity` (GPU-composited), never layout props
  (width/height/top) at 60fps.

### Slow startup

1. Measure: `npx react-native profile-hermes` or simple timestamps from
   native entry to first meaningful screen.
2. Common causes in order: oversized JS bundle (enable `inlineRequires`,
   lazy-require heavy screens), synchronous storage reads at boot, waterfall
   API calls before first render, uncompressed launch images.

### Memory growth

- Snapshot with Xcode Instruments (Allocations) / Android Studio Profiler.
- Usual suspects: listeners not removed on unmount, timers surviving
  navigation, image caches unbounded, closures capturing large objects in
  long-lived stores.

## Verification

After each fix, re-measure the SAME metric on a **release build on a real
mid/low-end device** — dev-mode and simulator numbers routinely mislead
(dev builds are 2–5× slower on JS).

## Anti-patterns

- Do NOT sprinkle `useMemo`/`useCallback`/`React.memo` everywhere "for
  performance" — unmeasured memoization adds cost and hides real problems.
- Do NOT set `windowSize={2}` style extreme values to hide heavy rows; blank
  cells while scrolling is a worse UX than the original jank.
- Do NOT conclude "React Native is slow" before checking the profile — the
  cause is almost always app-level (images, re-renders, bridge traffic).
