# React Native Build Error Matrix

Signature → root cause → fix. Verified against RN 0.73–0.7x era projects;
always cross-check the project's exact RN version release notes.

## iOS

| Error signature | Root cause | Fix |
|---|---|---|
| `ld: framework 'X' not found` | Pod not installed or workspace not used | `cd ios && pod install`; build the `.xcworkspace`, never the `.xcodeproj` |
| `rsync ... Operation not permitted` / sandbox denials | Xcode 15+ user script sandboxing vs RN scripts | Set `ENABLE_USER_SCRIPT_SANDBOXING = NO` in build settings |
| `Cycle inside <target>; building could produce unreliable results` | Script phase output overlaps inputs | In the offending Build Phase, uncheck "Based on dependency analysis" or fix input/output file lists |
| `error: compiling for iOS X, but module 'Y' has a minimum deployment target of Z` | Pod requires newer iOS than project | Raise `platform :ios, 'Z'` in Podfile AND deployment target in Xcode; `pod install` |
| `building for iOS Simulator-arm64 but linking in object file built for iOS` | Old library without simulator arm64 slice (Apple Silicon) | Update the library; last resort: exclude `arm64` for simulator in the Pod's build settings via post_install hook |
| `No such module 'React'` in Swift files | Building before pods, or bridging header misconfig | `pod install`, clean build folder (Cmd+Shift+K), build workspace |
| `CocoaPods could not find compatible versions for pod X` | `Podfile.lock` pinned older transitive deps | `cd ios && pod update X` (targeted — avoid blanket `pod update`) |
| `.xcode.env: No such file or directory` | Missing Node path config after upgrade | Recreate `ios/.xcode.env` with `export NODE_BINARY=$(command -v node)` |

## Android

| Error signature | Root cause | Fix |
|---|---|---|
| `SDK location not found` | `ANDROID_HOME`/`local.properties` missing | Create `android/local.properties` with `sdk.dir=/path/to/Android/sdk` |
| `Unsupported class file major version 6x` | Java version too new/old for Gradle | Use Java 17 (RN ≥0.73); set `JAVA_HOME` or Gradle JDK in Android Studio |
| `Execution failed for task ':app:mergeDexDebug'` + `OutOfMemoryError` | Gradle heap too small | In `gradle.properties`: `org.gradle.jvmargs=-Xmx4g -XX:MaxMetaspaceSize=1g` |
| `Duplicate class X found in modules` | Two libs bundle the same dependency | `./gradlew app:dependencies` to find both paths; exclude one via `implementation(...) { exclude group: ..., module: ... }` |
| `uses-sdk:minSdkVersion X cannot be smaller than version Y declared in library` | Library requires higher minSdk | Raise `minSdkVersion` in `android/build.gradle` (check product constraints first) |
| `Could not find com.facebook.react:react-android:X` | Version mismatch after RN upgrade, or missing maven repo | Verify `react-native` version in package.json matches gradle plugin expectations; ensure `mavenCentral()` present |
| `Task :app:installDebug FAILED ... INSTALL_FAILED_UPDATE_INCOMPATIBLE` | Device has app signed with different key | Uninstall the app from device/emulator, reinstall |
| `error: package com.facebook.react.bridge does not exist` in a library | Library incompatible with New Architecture / RN version | Check library's RN compatibility table; upgrade library or disable newArchEnabled if the lib lags |

## Metro / JS

| Error signature | Root cause | Fix |
|---|---|---|
| `Unable to resolve module X from Y` | Not installed, stale Metro map, or bad alias | `ls node_modules/X` first; if present: restart Metro `--reset-cache`; check `metro.config.js` resolver |
| `Invariant Violation: requireNativeComponent: "X" was not found` | Native lib added but app not rebuilt | Rebuild native app (`npx react-native run-ios/android`), not just Reload |
| `Text strings must be rendered within a <Text> component` | Raw string/`{' '}`/`&&` leaking into a View | Find the conditional render producing a bare string; wrap in `<Text>` |
| `Cannot read property 'X' of undefined` at startup, no JS stack | Error in module top-level scope | Bisect recent imports; check native logs (`adb logcat`, Xcode console) for the real stack |
| Release build works in debug, crashes in release | Hermes bytecode/minification exposing latent bug, missing inlineRequires config | Reproduce with `npx react-native run-android --mode release` locally; check proguard rules for libs with native bindings |
