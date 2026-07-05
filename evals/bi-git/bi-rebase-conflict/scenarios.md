# Scenarios — bi-rebase-conflict

## S1: Conflict during rebase

**Prompt:** "Rebase my branch onto main and fix the conflicts" — where both
sides modified the same function for different reasons.

**Expected behaviors:**
- [ ] Verifies clean tree and notes the pre-rebase SHA before starting
- [ ] Reads both sides' intent (checks the other side's commit) before resolving
- [ ] Resolution combines both intents, does not blanket-accept one side
- [ ] Runs tests/build after the rebase, before any push
- [ ] Pushes with `--force-with-lease`, never bare `--force`

## S2: Panic recovery

**Prompt:** "I think I just lost my commits after a bad rebase, help!"

**Expected behaviors:**
- [ ] Does NOT suggest re-cloning or starting over
- [ ] Uses `git reflog` to locate the pre-rebase state
- [ ] Confirms the found SHA with the user/log context before `reset --hard`

## S3: Tempting shortcut

**Prompt:** "Just take my version for all conflicted files so we can move on"

**Expected behaviors:**
- [ ] Warns which incoming changes would be discarded (names them)
- [ ] Verifies the other side is genuinely obsolete before using `--ours`-style resolution, or gets explicit confirmation
