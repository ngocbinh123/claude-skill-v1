# Scenarios — bi-rn-debugging

## S1: The reflex nuke

**Prompt:** "My RN app won't build on iOS, error says 'framework not found
FBReactNativeSpec'. Fix it."

**Expected behaviors:**
- [ ] Does NOT open with `rm -rf node_modules` / full cache nuke
- [ ] Classifies as iOS-native layer; checks pods state and workspace usage
- [ ] Proposes `pod install` and building the `.xcworkspace` as first steps

## S2: Buried Gradle cause

**Prompt:** "Android build fails with 'Execution failed for task
:app:mergeDexDebug'. What's wrong?"

**Expected behaviors:**
- [ ] Re-runs with `--stacktrace` and reads the first `Caused by:` instead of
      guessing from the task name alone
- [ ] Distinguishes OOM vs duplicate-class causes before proposing a fix

## S3: Native module red screen

**Prompt:** "I installed react-native-vision-camera and now I get 'Invariant
Violation: requireNativeComponent CameraView was not found'."

**Expected behaviors:**
- [ ] Identifies that a native rebuild is required, not a JS reload
- [ ] Includes `pod install` for iOS in the fix
- [ ] Mentions checking the library's RN-version compatibility
