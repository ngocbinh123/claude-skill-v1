---
name: ios-build-errors
description: Triage and fix Xcode build failures in native iOS projects (Swift/Objective-C), including CocoaPods and Swift Package Manager issues. Use when an iOS build fails, xcodebuild errors, code signing fails, pod install fails, or SPM cannot resolve packages.
---

# iOS Build Error Triage

## Overview

Classify the failure into one of five buckets — signing, dependencies,
compilation, linking, or Xcode environment — then apply that bucket's
playbook. Get the precise error from Xcode's issue navigator or:

```bash
xcodebuild -workspace App.xcworkspace -scheme App -destination \
  'generic/platform=iOS Simulator' build 2>&1 | grep -B2 -A8 "error:"
```

## Buckets

### Code signing

- `Signing for "App" requires a development team` → select a team in
  Signing & Capabilities; CI needs an exported provisioning profile or
  `-allowProvisioningUpdates` with an App Store Connect API key.
- `Provisioning profile doesn't include device/capability X` → regenerate the
  profile after adding devices/entitlements; capabilities in the entitlements
  file must be mirrored in the App ID configuration.
- Never fix signing by switching to "Automatically manage" mid-CI-run without
  understanding what profiles CI has access to.

### Dependencies — CocoaPods

- Always build the `.xcworkspace` after `pod install`, never `.xcodeproj`.
- `Could not find compatible versions for pod X` → targeted
  `pod update X`, not blanket `pod update`; check `platform :ios` floor.
- Sandbox/rsync `Operation not permitted` under Xcode 15+ →
  `ENABLE_USER_SCRIPT_SANDBOXING = NO`.
- Ruby errors running pod → prefer `bundle exec pod install` when a Gemfile
  exists (locks CocoaPods version per-project).

### Dependencies — SPM

- `Missing package product X` / resolution spins forever → File → Packages →
  Reset Package Caches; delete `DerivedData` only if reset fails; check the
  pinned revision in `Package.resolved` still exists upstream.

### Compilation

- `No such module 'X'` → the module isn't built yet for this configuration:
  build dependency target first, verify it's in Frameworks & Libraries, and
  for pods confirm it appears in the Podfile target actually being built.
- Swift version errors after Xcode upgrade → check `SWIFT_VERSION` per target
  and each dependency's minimum Swift tools version.

### Linking

- `ld: framework 'X' not found` → framework search paths, or pod not
  installed for this target/configuration.
- `Undefined symbols` naming a library type → library added to wrong target,
  or missing `-ObjC` linker flag required by that library's docs.
- `building for iOS Simulator-arm64 but linking ... built for iOS` → the
  dependency ships no simulator arm64 slice; update it (preferred) or exclude
  arm64 for simulator via post_install as a stopgap.

### Xcode environment

- Works for a teammate, not for you → compare Xcode versions first
  (`xcodebuild -version`), then `xcode-select -p` (points at full Xcode, not
  CommandLineTools), then clean `DerivedData`
  (`rm -rf ~/Library/Developer/Xcode/DerivedData/<App>-*`).

## Verification

After the fix, do one clean build (Cmd+Shift+K, then build) to confirm the
error is gone from a cold state, not hidden by incremental build artifacts.

## Anti-patterns

- Do NOT delete `DerivedData` as the first move — it costs a full rebuild and
  usually isn't the cause; use it after classification fails.
- Do NOT commit changes to `.pbxproj` made while randomly toggling build
  settings; revert experiments before the real fix.
- Do NOT disable warnings/errors globally (`GCC_TREAT_WARNINGS_AS_ERRORS`,
  ATS exceptions) to make one library compile.
