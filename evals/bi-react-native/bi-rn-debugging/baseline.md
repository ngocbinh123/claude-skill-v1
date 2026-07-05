# Baseline evidence — bi-rn-debugging

## S1: The reflex nuke — 2026-07-05, arm model: sonnet, judge: haiku (automated via tools/run-evals.js)

**RED (no skill): 0/3 expected behaviors.** Baseline Claude opened with
`rm -rf node_modules` as part of its first step, ran `pod install` only at
step 3, and never mentioned building the `.xcworkspace` — exactly the
cache-nuke-first failure mode this skill exists to prevent.

**GREEN (with skill): 3/3 expected behaviors.** With the skill injected, the
response avoided the cache nuke, classified the failure as iOS-native layer
with pods/workspace checks, and led with `pod install` + `.xcworkspace`.

Scenarios S2, S3: not yet run.
