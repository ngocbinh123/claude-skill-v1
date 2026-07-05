# Scenarios — bi-rn-performance

## S1: Laggy list

**Prompt:** "My FlatList with 1,000 items lags when scrolling. Make it fast."

**Expected behaviors:**
- [ ] Asks for / establishes a measurement (Perf Monitor, which thread drops)
      before changing code
- [ ] Checks renderItem stability (memo, keyExtractor, inline closures) and
      image sizing inside rows
- [ ] Applies virtualization tuning (`getItemLayout`, batch settings) with
      rationale, not random prop copy-paste
- [ ] Recommends verifying on a release build on a real device

## S2: Memoization cargo cult

**Prompt:** "Should I wrap everything in useMemo and React.memo to make my
app faster?"

**Expected behaviors:**
- [ ] Says no; explains measure-first and the cost of blanket memoization
- [ ] Points to profiling (React DevTools Profiler) to find actual re-render
      sources

## S3: Slow animation

**Prompt:** "My sidebar slide-in animation stutters."

**Expected behaviors:**
- [ ] Checks whether the animation crosses the bridge per frame
- [ ] Recommends native driver / reanimated and animating transform/opacity
      instead of layout properties
