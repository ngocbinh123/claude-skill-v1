---
name: bi-rn-debugging
description: Triage and fix React Native build and runtime failures on iOS, Android, and Metro. Use when a React Native app fails to build, crashes on launch, shows a red screen, Metro bundler errors, pod install fails, or Gradle fails in an RN project.
---

# React Native Debugging

## Overview

RN failures span four layers: **JS/Metro → native iOS → native Android →
environment**. Identify the layer FIRST from the error signature, then apply
that layer's playbook. Do not reach for `rm -rf node_modules` as step one —
cache-nuking without a diagnosis destroys the evidence.

## Step 1 — Identify the layer

| Signature contains | Layer |
|---|---|
| `Unable to resolve module`, `Metro`, red screen with JS stack | Metro/JS |
| `xcodebuild`, `.pbxproj`, `Pods`, `ld: framework not found` | iOS native |
| `FAILURE: Build failed`, `Gradle`, `AAPT`, `Execution failed for task` | Android native |
| `command not found`, Java/Ruby/Node version mismatch, works-on-other-machine | Environment |

## Step 2 — Layer playbooks

### Metro / JS

1. Read the top-most frame of the JS stack — RN errors bury the cause above
   framework noise.
2. `Unable to resolve module X`: check X is in `package.json` and installed;
   restart Metro with `npx react-native start --reset-cache` ONLY after
   confirming the module exists on disk (`ls node_modules/X`).
3. Red screen `Invariant Violation`: usually a component rendered outside its
   provider, or native module missing after adding a library → rebuild the
   native app, not just reload JS.
4. Hermes-specific crashes: check the error also reproduces with a dev build
   before blaming Hermes.

### iOS

1. Build from Xcode once (`open ios/*.xcworkspace`) — its error panel is far
   more precise than the CLI dump.
2. After ANY dependency change: `cd ios && pod install`. Version drift between
   `Podfile.lock` and `node_modules` is the #1 iOS failure.
3. See [references/common-build-errors.md](references/common-build-errors.md)
   for the signature → fix matrix (sandbox rsync, framework not found,
   deployment target, M-series arch issues).

### Android

1. Re-run with `cd android && ./gradlew app:assembleDebug --stacktrace` and
   read the FIRST `Caused by:` in the chain — Gradle buries root causes.
2. After dependency changes, check for duplicate/conflicting native versions:
   `./gradlew app:dependencies | grep -A2 <lib>`.
3. See [references/common-build-errors.md](references/common-build-errors.md)
   for the signature → fix matrix (SDK location, heap size, minSdk conflicts,
   duplicate classes).

### Environment

Verify in order: `node -v` (match `.nvmrc`/engines), `java -version` (17 for
RN ≥0.73), `ruby -v` + `bundle exec pod install` if the project uses a
Gemfile, Xcode version vs project requirement, `ANDROID_HOME` set.

## Step 3 — Clean rebuild (only after diagnosis, or as last resort)

Escalate gradually, cheapest first:

```bash
npx react-native start --reset-cache        # 1. Metro cache
rm -rf ios/build android/app/build          # 2. native build outputs
cd ios && pod deintegrate && pod install    # 3. pods
watchman watch-del-all                      # 4. watchman
rm -rf node_modules && npm install          # 5. node_modules (last)
```

If a full clean fixes it, still identify WHICH step fixed it — that tells you
the real cause and prevents recurrence.

## Anti-patterns

- Do NOT suggest the full cache-nuke chain as the first response.
- Do NOT change library versions "to see if it helps" without reading the
  library's compatibility table against the project's RN version.
- Do NOT silence native build warnings with build-setting flags without
  understanding what the warning protects against.
