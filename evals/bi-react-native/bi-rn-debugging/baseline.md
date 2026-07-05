# Baseline evidence — bi-rn-debugging

## S1: The reflex nuke — 2026-07-05, arm model: sonnet, judge: haiku (automated via tools/run-evals.js)

**RED (no skill): 0/3 expected behaviors.** Baseline Claude opened with
`rm -rf node_modules` as part of its first step, ran `pod install` only at
step 3, and never mentioned building the `.xcworkspace` — exactly the
cache-nuke-first failure mode this skill exists to prevent.

**GREEN (with skill): 3/3 expected behaviors.** With the skill injected, the
response avoided the cache nuke, classified the failure as iOS-native layer
with pods/workspace checks, and led with `pod install` + `.xcworkspace`.

## S2, S3 — 2026-07-05 (with-skill arm)

S2 initially failed 1/2 (assumed duplicate-class without ruling out OOM);
after the 0.1.1 fix (stacktrace decides OOM vs duplicate classes) S2 passes
2/2. S3 passed 3/3 on first run. Baseline (RED) arms for S2/S3 not yet
recorded.
