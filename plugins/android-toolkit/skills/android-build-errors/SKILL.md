---
name: android-build-errors
description: Triage and fix Gradle build failures in native Android projects (Kotlin/Java). Use when an Android build fails, Gradle sync fails, or errors mention Gradle tasks, AGP, AAPT, manifest merger, or dependency resolution.
---

# Android Build Error Triage

## Overview

Gradle buries root causes. The diagnosis loop is always: get the FIRST
`Caused by:`, classify it, fix at the source — never silence with flags you
don't understand.

## Step 1 — Get the real error

```bash
./gradlew app:assembleDebug --stacktrace
```

Read the LAST failed task name and the FIRST `Caused by:` in its chain. The
task name tells you the phase: `compile*` (code), `merge*` (resources/
manifest), `process*` (resources), `dex*`/`minify*` (packaging), `lint*`.

## Step 2 — Classify and fix

### Toolchain mismatches (most common after upgrades)

- `Unsupported class file major version` → Java version vs Gradle version.
  Check the AGP↔Gradle↔JDK compatibility table for the project's AGP version;
  set the Gradle JDK (Android Studio settings or `JAVA_HOME`).
- `The project is using an incompatible version of the Android Gradle plugin`
  → align `com.android.tools.build:gradle` with `gradle-wrapper.properties`.
- Kotlin errors after upgrade → `kotlin-gradle-plugin` version must be
  compatible with AGP and with Compose compiler version if Compose is used.

### Dependency resolution

- `Duplicate class X` → `./gradlew app:dependencies` to locate both bringers;
  `exclude` one, or force a single version via `resolutionStrategy`.
- `Could not resolve X` → check repository blocks (`mavenCentral()`,
  `google()`), then whether the version exists; corporate proxies need
  explicit repo mirrors.
- Manifest merger failed → the error names both manifests; fix with
  `tools:replace`/`tools:node` in the app manifest only when you understand
  which value must win.

### Resources

- `AAPT: error: resource X not found` → typo, missing qualifier variant, or
  a library referencing resources for a newer `compileSdk`.
- `Resource compilation failed` on 9-patch/PNG → re-export the asset.

### Memory / daemon weirdness

- `OutOfMemoryError` during dex/minify → `gradle.properties`:
  `org.gradle.jvmargs=-Xmx4g -XX:MaxMetaspaceSize=1g`.
- Inexplicable stale behavior → `./gradlew --stop && ./gradlew clean` (kills
  daemons holding old classpaths). This is the LAST resort, not the first.

## Verification

Re-run the same task after each single change. If you changed versions,
run `./gradlew app:dependencies > /tmp/deps.txt` before and after and diff —
confirm the change did what you intended and nothing else.

## Anti-patterns

- Do NOT add `android.enableJetifier`/`multiDexEnabled`/`tools:replace`
  reflexively — each masks a class of real problems.
- Do NOT bump `compileSdk`/`targetSdk` just to silence one library warning
  without checking behavior changes for the new API level.
- Do NOT run `./gradlew clean` before capturing the error output — you
  destroy incremental state that makes reproduction fast.
