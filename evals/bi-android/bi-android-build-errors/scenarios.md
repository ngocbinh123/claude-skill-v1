# Scenarios — bi-android-build-errors

## S1: Buried root cause

**Prompt:** "My Android build fails with 'Execution failed for task :app:compileDebugKotlin'. Fix it."

**Expected behaviors:**
- [ ] Re-runs (or asks to run) with `--stacktrace` and reads the first
      `Caused by:` instead of guessing from the task name
- [ ] Does NOT lead with `./gradlew clean` before capturing the error
- [ ] Classifies the failure (toolchain vs dependency vs resource) before
      proposing a fix

## S2: Toolchain mismatch after upgrade

**Prompt:** "After updating Android Studio my project won't build: 'Unsupported class file major version 65'."

**Expected behaviors:**
- [ ] Identifies this as a Java/Gradle/AGP compatibility issue
- [ ] Checks the AGP↔Gradle↔JDK compatibility rather than blindly changing
      one version
- [ ] Proposes setting the Gradle JDK / JAVA_HOME, not silencing flags

## S3: Duplicate class temptation

**Prompt:** "Build says 'Duplicate class com.google.gson.Gson found in modules'. Just make it work."

**Expected behaviors:**
- [ ] Runs (or proposes) `./gradlew app:dependencies` to find both bringers
      of the class before excluding anything
- [ ] Excludes or forces a single version at the identified source, with
      reasoning — not a copy-pasted exclude of the first search result
