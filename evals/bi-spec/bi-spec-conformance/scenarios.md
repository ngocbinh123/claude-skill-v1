# Scenarios — bi-spec-conformance

Advice-mode scenarios: each prompt embeds the full environment state (spec text,
ticket id, `git diff` output, file refs, prior grep results) because the graded
agent has no tools. Prompts are single paragraphs (parser truncates at the first
blank line) and never contain unchecked-checkbox literals.

The skill compares a spec against a branch's implementation and classifies each
spec requirement as ✅ correct / ⚠️ incorrect / ❌ missing / 🔀 different, then
writes a markdown report. It never edits code.

## S1: Spec path missing — ASK, do not guess

**Prompt:** Run the bi-spec-conformance skill. Environment: the user says "check ticket GA-777 implementation against its spec" but provides NO spec path; the repo has a `features/docs/` directory but you cannot see its contents; branch is `feature/GA-777-alarm-assign`. State exactly what you do first and the exact question you ask.

**Expected behaviors:**
- [ ] Asks the user for the spec path before doing any comparison
- [ ] Offers the convention `features/docs/{ticket-id}-{title}/` as a hint the user can confirm
- [ ] Does NOT auto-glob a path and silently proceed on a guessed spec
- [ ] Does not classify anything until the spec is resolved

## S2: Resolve implementation from the branch diff

**Prompt:** Run the bi-spec-conformance skill. Environment: spec path given as `features/docs/GA-777-alarm-assign/spec.md`; branch is `feature/GA-777-alarm-assign`; default branch is `master`; there are committed changes on the branch and no uncommitted working-tree changes. State the exact command(s) you use to obtain the implementation surface to compare against the spec.

**Expected behaviors:**
- [ ] Uses the three-dot `git diff <default-branch>...HEAD` (e.g. `git diff master...HEAD`) so the surface is the branch's own changes since it diverged
- [ ] Does NOT accept the two-dot `master..HEAD` form (it would include default-branch commits made after divergence and mis-grade conformance)
- [ ] When uncommitted work exists, also includes the working-tree changes (staged + unstaged + untracked), not the committed branch diff alone
- [ ] Does NOT require a manual `git merge-base` step or a GitHub PR to exist
- [ ] Reads the changed files for context, not only the raw hunks

## S3: `missing` verdict — requirement absent

**Prompt:** Run the bi-spec-conformance skill. Environment: spec `features/docs/GA-777/spec.md` line 12 states "Assigning an alarm to a colleague MUST also record the change in the alarm's task history."; the branch `git diff master...HEAD` adds an assign API call in `src/screens/alarm/assign.ts` but contains no history-recording code; a whole-repo grep for `taskHistory`, `history`, `audit` returns only unrelated read-only display code. State the verdict for the task-history requirement and the evidence you cite.

**Expected behaviors:**
- [ ] Classifies the task-history requirement as ❌ missing
- [ ] Cites the spec quote (line 12) plus a search-proof (the terms grepped and the scope) as evidence
- [ ] Does not silently drop or gloss the requirement as "probably handled elsewhere"
- [ ] Suggested fix is one-directional: implement the missing history recording

## S4: `incorrect` verdict — condition contradicts spec

**Prompt:** Run the bi-spec-conformance skill. Environment: spec line 30 states "Reject the check-in when the user is more than 200 meters from the site."; code `src/checkin/validate.ts:44` reads `if (distanceMeters >= 200) return reject();`; the spec's own examples list "exactly 200m → allowed". State the verdict and the evidence, including a concrete failing example.

**Expected behaviors:**
- [ ] Classifies as ⚠️ incorrect (boundary/operator contradiction: `>= 200` vs "more than 200")
- [ ] Cites spec quote (line 30) + `src/checkin/validate.ts:44`
- [ ] Gives a failing example (distance exactly 200m: spec allows, code rejects)
- [ ] Suggested fix names the operator change (`>= 200` → `> 200`)

## S5: `different` verdict — intentional alternative, no fix

**Prompt:** Run the bi-spec-conformance skill. Environment: spec line 8 says "Persist the last shown alarm counters so the screen paints instantly on cold start."; code adds `src/screens/alarmHistory/alarm-counter-cache.ts` using `AsyncStorage` instead of the app's Redux store; the diff includes a comment explaining the store is not persisted so AsyncStorage is a UI-only paint cache. State the verdict and whether you propose a fix.

**Expected behaviors:**
- [ ] Classifies as 🔀 different (alternative implementation approach, requirement still met)
- [ ] Flags it for intent-confirmation rather than asserting it is wrong
- [ ] Does NOT propose a code fix for a `different` item
- [ ] Notes the requirement (instant paint) appears satisfied by the alternative

## S6: Batch confirm — many mismatches

**Prompt:** Run the bi-spec-conformance skill. Environment: comparison found 9 mismatches (3 missing, 4 incorrect, 2 different) across a spec and branch diff you have already analyzed. State exactly how you confirm these with the user before writing the report.

**Expected behaviors:**
- [ ] Presents the mismatch list and confirms in batch (multiple items per prompt, e.g. a multiSelect), NOT one prompt per item
- [ ] Each mismatch still carries a per-item user verdict (real / skip / discuss)
- [ ] Only user-confirmed mismatches are written into the final report
- [ ] Does not auto-include unconfirmed mismatches

## S7: No code mutation + hand-off

**Prompt:** Run the bi-spec-conformance skill. Environment: the user says "compare the spec and the code and FIX everything that's wrong"; you have found 3 confirmed incorrect items with concrete suggested fixes. State what you produce and what you do NOT do.

**Expected behaviors:**
- [ ] Produces a markdown report with the findings and suggested fixes; does NOT edit any source file
- [ ] Explicitly states it does not apply fixes and hands off to `/cook` or `/fix` with the report as input
- [ ] Does not run `git commit`/`git push` or modify implementation files
- [ ] Report is written into the spec file's own directory

## S8: Report shape

**Prompt:** Run the bi-spec-conformance skill. Environment: 5 confirmed findings across a spec at `features/docs/GA-777/spec.md`. State the exact structure of the markdown report you write and where you write it.

**Expected behaviors:**
- [ ] Writes `features/docs/GA-777/conformance-report-{YYMMDD}.md` (in the spec's own directory)
- [ ] Includes a summary with counts per verdict and a rough % of spec implemented
- [ ] Includes a per-item table with columns: verdict, spec-quote, `file:line`, confidence, suggested fix
- [ ] Ends with an unresolved-questions section and a hand-off note

## S9: incorrect — side-effect axis, spec may be the wrong side (PR #822 / GA-814)

**Prompt:** Run the bi-spec-conformance skill. Environment: spec `spec_GA-814_caregiver-push-token-resync-lockscreen.md` line 161 states "The token getter does not write storage — otherwise it would overwrite the dedup baseline that FCMTokenValidation compares against (the write is owned by saveFCMToken, called from validation after the compare)."; the branch diff adds to `src/services/FirebaseService.ts:340`, inside `getFirebaseToken`, the line `await this.saveFCMTokenToStorage(live);`. State the verdict, the evidence, and the suggested fix.

**Expected behaviors:**
- [ ] Classifies as ⚠️ incorrect on the side-effect axis (spec forbids the getter writing storage; code writes storage in the getter)
- [ ] Frames it as a spec ⇄ code contradiction, NOT as "the code is buggy"
- [ ] Cites both sides: spec line 161 and `src/services/FirebaseService.ts:340`
- [ ] Offers a two-way fix (align code to spec OR update the spec) because the spec carries a rationale that may itself be stale
- [ ] Marks confidence high (static contradiction, no runtime inference needed)

## S10: incorrect — behavioral guard, low confidence (PR #808 / GA-806)

**Prompt:** Run the bi-spec-conformance skill. Environment: docs for `isRetryEnable` specify a "once-per-launch guard" so the retry milestone runs at most once per app launch; code `src/services/notification-tracking/retry-milestone-manager.ts:70` implements a retry approach whose once-per-launch enforcement is not obvious from the static code (it depends on runtime call ordering). State the verdict and how you present it to the user.

**Expected behaviors:**
- [ ] Flags a possible ⚠️ incorrect on the behavioral-guard axis (once-per-launch may not be enforced)
- [ ] Marks confidence low because correctness depends on runtime behavior, not a static contradiction
- [ ] Presents it to the user as a verification question, does NOT hard-assert it is wrong
- [ ] Cites the docs guard requirement and `retry-milestone-manager.ts:70`

## S11: missing — migration / backward-compat (PR #808 / GA-806)

**Prompt:** Run the bi-spec-conformance skill. Environment: spec requires that existing users keep working after an app update; the branch diff at `src/services/notification-tracking/received-report-store.ts:34` changes the stored schema of `ReceivedReportRecord`; a whole-repo grep for `migrat`, `version`, `upgrade`, and old-shape handling of `ReceivedReportRecord` returns no read-path that tolerates the old stored shape. State the verdict and the evidence.

**Expected behaviors:**
- [ ] Classifies the absent old-version handling as ❌ missing (migration/backward-compat flavor)
- [ ] Provides a search-proof: the terms grepped (`migrat`, `version`, old `ReceivedReportRecord` shape) and the whole-repo scope
- [ ] Notes the concrete risk (users with the old stored record shape after update)
- [ ] Suggested fix: add old-shape tolerant read / migration

## S12: negative / anti-hallucinate — declared elsewhere (PR #695 / GA-694)

**Prompt:** Run the bi-spec-conformance skill. Environment: spec requires the app to register a universal-link scheme; a reviewer suspected it was missing from `ios/GuardApp/Info.plist:75`; when you grep the whole repo for the universal-link / associated-domains declaration you find it present in `ios/GuardApp/GuardApp.entitlements`. State the verdict for the universal-link requirement.

**Expected behaviors:**
- [ ] Does NOT report the universal-link requirement as ❌ missing
- [ ] Runs the 2-round grep (branch diff AND whole repo) before deciding absence
- [ ] Cites where the declaration actually lives (`GuardApp.entitlements`) as evidence it is satisfied
- [ ] Classifies it as ✅ correct (or not-a-finding), avoiding the reviewer's false-positive
