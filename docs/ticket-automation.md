# AI ticket pipeline — design spec

Board: <https://github.com/users/ngocbinh123/projects/2>
Status columns: `Backlog` → `Ready` → `In progress` → `In review` → `Done`

Hybrid architecture agreed on 2026-07-10. This document is the source of
truth: it contains everything needed to rebuild the system on a new machine.

> **Implementation status:** IMPLEMENTED (2026-07-10). The dispatcher reads
> board Status directly, so the mirror workflow
> (`.github/workflows/ticket-status-automation.yml`) is obsolete and stays
> disabled. All AI work runs in `tools/ai-ticket-dispatcher.sh`, and the
> schedule is a Claude Code routine (`ai-ticket-dispatcher`, currently
> paused). A launchd template is kept as the app-independent alternative at
> `tools/com.ngocbinh123.ai-ticket-dispatcher.plist`. Activation gated on
> the setup checklist in §8 (pre-labels + merge to master + dry-run).

## 1. Why hybrid (CI detects, local executes)

- GitHub Actions has **no trigger for Projects v2 Status changes** — the only
  reliable detection is polling the board via GraphQL.
- CI-side AI (Copilot / GitHub Models) sees only the ticket text. Local
  execution runs Claude Code with the full personal skill set
  (`~/.claude/skills`: `ck:brainstorm`, `ck:vibe`, `binh-gh-*`) **and the real
  codebase**, which produces far better analysis and implementation.
- CI keeps running when the Mac is off, so nothing is lost: state lives in
  GitHub labels, and the local worker drains the backlog when it comes online.

```
Local dispatcher (Claude Code routine)
──────────────────────────────────────
read board Status via GraphQL (source of truth)
act only on Ready / In progress / In review
claim → run Claude skill → mark result
worker pool, priority, kill-switch
```

## 2. Trigger conditions (state-based, not transition-based)

A handler runs when the ticket's *current state* matches. No transition
history needed. Status is read straight from the project board each cycle;
an issue absent from the board, or parked in any other column (Backlog,
Done), is never touched. Claim labels track in-flight work only.

| Handler | Condition (ALL must hold) | Action |
| --- | --- | --- |
| **BRAINSTORM** (once) | board `Ready` AND no `planning`/`planned` AND no `agent-ignore` | claim with `planning` → `claude -p "/ck:brainstorm …"`: structured analysis (Goal / Scope / Out of scope / Verification TDD / Ideas / Open questions — full prompt in §7) → post the FULL analysis as ONE issue comment marked `<!-- ai-brainstorm -->` → swap `planning` → `planned` only after the comment is verified to exist |
| **COOK** (once) | board `In progress` AND no `cooking`/`cooked` AND no `agent-ignore` | claim with `cooking` → `claude -p "/ck:vibe <issue-url>"` which FIRST reads the `<!-- ai-brainstorm -->` comment as the requirement contract (scope, out-of-scope, TDD test list — full prompt in §7): worktree → plan → TDD implement (tests must pass — hard gate) → push branch → create PR → **immediately** move board Status to `In review` (do not wait for CI green) + comment PR link → swap `cooking` → `cooked` only after the PR is verified to exist |
| **REVIEW-WATCH** (session once; merged/closed check always) | board `In review` AND `cooked` AND no `agent-ignore` | always run cheap merged/closed check (§3.1); if no `reviewing`/`reviewed`, claim with `reviewing` → review-fix session (§3) → swap `reviewing` → `reviewed` |

Notes:

- Independent stages: a ticket dragged straight to `In progress` gets cooked
  without a prior brainstorm (deliberate: the human decided it's clear enough).
- A ticket created directly in `Ready` IS picked up (state-based check has no
  "first sighting" gap).
- **Re-run** = manually remove `planned` / `cooked` / `reviewed`.
  Removing `reviewed` is also how a new round of review feedback gets
  processed — the agent does NOT auto-resume on new comments.
- **Force-run** on any ticket = just ensure it sits in the right column
  without the done-marker label.
- **Skip forever** = add `agent-ignore` (§4).

## 3. REVIEW-WATCH handler (cheap → expensive ladder)

Claude session is one-shot like COOK: it runs once, marks `reviewed`, then ignores the ticket
until a human removes `reviewed`. The merged/closed check (§3.1, plain bash) is a separate cheap check
that runs every cycle even when `reviewed` is present:

1. `gh pr view --json state,mergedAt` (plain bash, no tokens):
   - **MERGED** → move board Status to `Done`, comment "merged in <PR>", stop
     watching forever.
   - **CLOSED without merge** → add `agent-ignore` + explanatory comment.
   - **OPEN** → step 2.
2. Anything NEW since last processed timestamp? (stored in a hidden marker
   comment on the PR; still plain bash)
   - Marker format — a PR comment whose entire body is:
     `<!-- ai-review-watch: last=2026-07-10T10:00:00Z -->`
     (ISO-8601 UTC). One marker comment per PR, edited in place on each
     session (never a new comment). No marker yet = everything is new.
   - New review comments after `last`, or CI turned red → step 3.
     Otherwise exit (0 tokens).
3. Claim with `reviewing`, then a single `claude -p` session (full prompt
   in §7):
   - Triage new comments by severity. **Fix only critical + high + CI
     failures.** Medium/low → short reply "noted, deferred", no code.
     Reviewers can force priority by writing `critical:` in a comment.
   - Commit, push to the PR branch, reply to each addressed comment with the
     fix commit SHA.
   - **CI-fix limit: 3 attempts per session.** Still red after 3 → add
     `agent-ignore` to the ticket + comment on both PR and ticket summarizing
     the 3 attempts. Human fixes, then removes `agent-ignore` to resume.
4. After the session (success or give-up): update the marker comment to the
   current time, then **swap `reviewing` → `reviewed`** (on give-up,
   `agent-ignore` is added as well). New review comments arriving after
   `reviewed` are NOT auto-processed — a human removes `reviewed` to run
   another session; the timestamp marker then scopes it to what's new.
   A `reviewing` label older than `STALE_CLAIM_HOURS` means a crashed
   session → stale-claim recovery (§4).

## 4. `agent-ignore` — global kill-switch

- First check of every handler: label present → the agent does **nothing**
  for that ticket (no brainstorm/cook/review-watch, not even the merged
  check). Nothing else runs for it.
- Humans add/remove it freely to take over any ticket.
- The only automatic writer: CI-fix limit above. Every "needs a human" state
  is uniformly `agent-ignore` + an explanatory comment (no separate
  `*-failed` label taxonomy).
- Stale-claim recovery: a ticket stuck in `planning`/`cooking`/`reviewing`
  for > 2 h (crash mid-run) → dispatcher adds `agent-ignore` + comment
  "run interrupted, remove agent-ignore to retry". Never auto-requeue (a
  half-pushed branch must not be cooked twice blindly).

## 5. Scheduling, concurrency, priority

Dispatcher config (env vars or a small config file next to the script):

```bash
MAX_WORKERS=3        # parallel claude -p sessions (2–3 recommended)
MAX_COOK_WORKERS=1   # cook cap — keep 1: parallel test suites starve CPU
                     # and cause flaky-timeout TDD failures; raise only after
                     # observing machine load
POLL_INTERVAL=600    # scheduler interval, seconds (routine cron */10, or
                     # launchd StartInterval in the alternative setup)
STALE_CLAIM_HOURS=2
```

Per cycle:

1. Global **lock file**: if the previous cycle is still running, exit.
2. Cheap review checks (§3 steps 1–2) run first, sequentially, outside the
   worker pool — seconds for a dozen PRs.
3. Build ONE priority queue of tickets needing a Claude session:
   - by Status: **In review → In progress → Ready**
     (value lies in pushing tickets over the finish line, not starting more);
   - within a Status: board `Priority` field if present, else FIFO (lowest
     issue number first).
4. Fill the pool (`MAX_WORKERS` slots, cook capped separately). Claim labels
   (`planning`/`cooking`/`reviewing`) are swapped in **before** a session
   starts, so workers never collide and overlapping cycles never double-run.
5. Leftovers stay queued by their labels — picked up next cycle.

Throughput reality: ~1 cook/hour max. Dragging 10 tickets into
`In progress` occupies the machine for a day — intended; the pipeline
self-throttles to human review speed.

## 6. Label reference

| Label | Writer | Meaning |
| --- | --- | --- |
| `status:<value>` | (none) | Legacy board mirror. No longer read or written — the dispatcher queries board Status directly. Safe to delete. |
| `planning` / `planned` | dispatcher | Brainstorm running / done |
| `cooking` / `cooked` | dispatcher | Cook running / done (PR exists) |
| `reviewing` / `reviewed` | dispatcher | Review-fix session running / done. Remove `reviewed` to process a new round of feedback (§3.4). Merged/closed check ignores these labels. |
| `agent-ignore` | human, or agent on give-up | Kill-switch: agent skips this ticket entirely |

Reading a ticket's labels answers "has it been processed, and where is it in
the pipeline" at a glance; board views can filter on them.

## 7. Components to build

| Component | Path | Job |
| --- | --- | --- |
| CI workflow (obsolete) | `.github/workflows/ticket-status-automation.yml` | Was the board→`status:*` label mirror. The dispatcher now reads board Status directly, so this is dead weight: keep it disabled or delete it. |
| Dispatcher | `tools/ai-ticket-dispatcher.sh` | everything in §2–§5; `--dry-run` flag prints planned actions without executing |
| Scheduler (primary) | Claude Code routine `ai-ticket-dispatcher` (`~/.claude/scheduled-tasks/ai-ticket-dispatcher/SKILL.md`) | cron `*/10 * * * *`: run one `bash tools/ai-ticket-dispatcher.sh` cycle and summarize the output. Runs only while the Claude Code app is open; a missed run fires on next launch (acceptable: labels persist, backlog drains). |
| Scheduler (alternative, app-independent) | `tools/com.ngocbinh123.ai-ticket-dispatcher.plist` → copy to `~/Library/LaunchAgents/` | launchd agent, `StartInterval` = `POLL_INTERVAL`; logs to `~/Library/Logs/ai-ticket-dispatcher.log`. Use INSTEAD of the routine, never both. |

Dispatcher skill invocations (labels/comments via `gh`; board moves via
`gh api graphql` mutation `updateProjectV2ItemFieldValue`):

```bash
# brainstorm
claude -p "/ck:brainstorm 'Analyze and clarify the requirement of issue #<N> (<url>).
Produce a structured analysis with EXACTLY these sections:

## Goal
What outcome the ticket wants and why (one paragraph, user-visible value).

## Scope
Concrete list of what WILL be done: files/modules touched, behaviors added
or changed.

## Out of scope
Explicit list of what will NOT be done, including tempting adjacent work
to defer. If a scope decision is ambiguous, state the assumption made.

## Verification (TDD)
The test list that proves the work is done: for each scope item, the
test(s) to write FIRST (name, level unit/integration, what it asserts),
plus how to run them. These tests become the hard gate for the cook stage.

## Ideas / solution approaches
2–3 candidate approaches with trade-offs; mark the recommended one and why.

## Open questions
Anything blocking implementation that needs a human answer (empty if none).

Post the FULL analysis (all sections above, not a summary) as ONE comment
on issue #<N>, prefixed with the marker line <!-- ai-brainstorm -->.'"

# cook (vibe pipeline: worktree → plan → TDD cook → ship PR → CI watch)
claude -p "/ck:vibe <issue-url>
Before planning, read the issue comments and locate the latest comment
marked <!-- ai-brainstorm -->. Treat it as the requirement contract:
implement the Goal within Scope, do NOT touch Out-of-scope items, write
the tests from the Verification (TDD) section first and make them the
pass/fail gate, and prefer the recommended approach from Ideas unless the
codebase contradicts it (if you deviate, say why in the PR description).
If no brainstorm comment exists, proceed from the issue body alone and
note that in the PR description."

# review-watch (dispatcher pre-computes the <...> values in bash, step §3.2)
claude -p "PR <pr-url> for issue #<N>. New review comments since <last>:
<comment list: author, timestamp, body, comment-url>.
CI status: <green | red, with failing job names and log links>.

Triage each new comment by severity (critical / high / medium / low).
A comment starting with 'critical:' is always critical. Fix ONLY
critical + high + CI failures, in the PR's worktree/branch:
- For each fix: commit, push to the PR branch, reply to the addressed
  comment with the fix commit SHA.
- Medium/low: reply exactly 'noted, deferred' — do not change code.
- CI red: diagnose from the logs and fix. HARD LIMIT: 3 fix attempts
  this session. If CI is still red after the 3rd push, stop and print
  the line GIVE-UP: <one-line summary of the 3 attempts> as your final
  output (the dispatcher turns this into agent-ignore + comments).
Never force-push, never push to master, never merge the PR."
```

Success criteria the dispatcher checks before swapping done-markers
(exit code 0 alone is NOT success):

- brainstorm: a new issue comment containing `<!-- ai-brainstorm -->`
  exists → swap `planning` → `planned`. Otherwise leave `planning` for
  stale-claim recovery (§4).
- cook: an open PR referencing the issue, created after the dispatcher added `cooking`, exists → swap `cooking` → `cooked`.

Headless permission note: an unattended `claude -p` cannot answer a permission
prompt — a blocked tool call is dropped silently and the session drifts off its
task. Sessions therefore run with `--dangerously-skip-permissions`
(`BYPASS_PERMISSIONS=1`, the default), accepting that a session may run any
command inside `REPO_DIR`. Set `BYPASS_PERMISSIONS=0` to fall back to the
`CLAUDE_ALLOWED_TOOLS` allowlist, which must then cover `gh`, `git`, the test
runner, and `bash`/`sh` for verification scripts. Never push to `master`;
branches + PRs only.

`/ck:vibe` builds its worktree outside `REPO_DIR`, so `CLAUDE_EXTRA_DIRS` is
passed as `--add-dir`; without it every tool call in that worktree is rejected
as an out-of-sandbox path.

Session bounding: each `claude -p` is killed after `SESSION_TIMEOUT_SECS`
(default 1800). A session that loses the API otherwise retries for the better
part of an hour while holding its worker slot. Session transcripts are written
to `LOG_DIR` (default `~/.claude/logs/ai-ticket-dispatcher/<cycle>/`) and
survive the cycle, so a failed handler stays debuggable.

## 8. Setup checklist (repeat on any new machine)

One-time, GitHub side (survives machine changes):

1. `PROJECT_TOKEN` repo secret — PAT for `ngocbinh123`: classic scopes
   `project` + `repo`, or fine-grained *Projects: read* + *Issues:
   read/write*. (Default `GITHUB_TOKEN` cannot read Projects v2.)
2. Merge this branch to `master` — scheduled workflows only run from the
   default branch.
3. **Before first activation**, pre-label tickets already sitting in active
   columns that must NOT be processed: add `cooked` to tickets already in
   `In progress` (e.g. #3, #6, #8), `planned` to tickets in `Ready` you don't
   want brainstormed. State-based triggers WILL pick up everything eligible
   on the first sweep.

Per machine:

4. Prereqs: `gh auth login` (repo + project scopes), `claude` CLI logged in,
   personal skills present in `~/.claude/skills` (`ck:*`, `binh-gh-*`).
5. Create the Claude Code routine `ai-ticket-dispatcher` (cron
   `*/10 * * * *`) whose prompt runs one
   `bash tools/ai-ticket-dispatcher.sh` cycle and summarizes the output —
   or, for an app-independent setup, install the launchd plist instead
   (`cp tools/com.ngocbinh123.ai-ticket-dispatcher.plist ~/Library/LaunchAgents/`
   + `launchctl load …`). One scheduler only, never both.
6. First run with `--dry-run`: verify the planned actions, then enable the
   routine (it is created paused). For the routine, click "Run now" once to
   pre-approve its Bash permission so future runs don't stall on prompts.

## 9. Operating notes

- Worst-case latency from card drag to AI start: ~25 min (15 CI + 10 local).
- Mac off → tickets wait in queue (labels persist); drained on wake.
- Forensics order: ticket labels → ticket/PR comments → dispatcher log.
- `In review → Done` is automated on merge; merging the PR *is* the human
  approval gate. Everything before merge that needs a human is surfaced as
  `agent-ignore` + comment.
