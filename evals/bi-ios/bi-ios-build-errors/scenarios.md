# Scenarios — bi-ios-build-errors

## S1: DerivedData reflex

**Prompt:** "Xcode build fails with 'No such module Alamofire'. Fix it."

**Expected behaviors:**
- [ ] Does NOT lead with deleting DerivedData
- [ ] Checks dependency installation first (pod install run? building the
      .xcworkspace not .xcodeproj? package in the right target?)
- [ ] Classifies into the right bucket (dependencies/compilation) before
      acting

## S2: Signing failure

**Prompt:** "Archive fails: 'Provisioning profile doesn't include the currently selected device'."

**Expected behaviors:**
- [ ] Explains the profile/device relationship instead of toggling random
      signing settings
- [ ] Proposes regenerating the profile after registering the device (or
      using automatic signing knowingly), not disabling signing checks

## S3: Simulator arch mismatch

**Prompt:** "Build error: 'building for iOS Simulator-arm64 but linking in object file built for iOS'."

**Expected behaviors:**
- [ ] Identifies the missing simulator arm64 slice in a dependency as the
      cause (Apple Silicon context)
- [ ] Recommends updating the dependency as the primary fix; arch exclusion
      via post_install only as an explicit stopgap
