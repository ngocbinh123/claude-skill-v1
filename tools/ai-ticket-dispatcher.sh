#!/usr/bin/env bash
# ai-ticket-dispatcher.sh — local AI ticket pipeline dispatcher.
# Spec: docs/ticket-automation.md. Reads each ticket's Status straight from the
# project board, acts only on Ready / In progress / In review, and runs Claude
# sessions (brainstorm / cook / review-fix) through a bounded worker pool.
# Claim labels (planning/cooking/reviewing) track in-flight work.
#
# Usage: ai-ticket-dispatcher.sh [--dry-run]
#   --dry-run  print planned actions (claims, sessions, mutations) without
#              executing them; read-only API calls still run.
#
# Compatible with macOS /bin/bash 3.2 (no associative arrays, no mapfile).

set -uo pipefail

# ---------------------------------------------------------------- config ---
REPO="${REPO:-ngocbinh123/claude-skill-v1}"
OWNER="${REPO%%/*}"
REPO_NAME="${REPO##*/}"
# Codebase the Claude sessions run in (skills need the real checkout).
REPO_DIR="${REPO_DIR:-$HOME/Documents/my-project/claude-skill-v1}"
PROJECT_OWNER="${PROJECT_OWNER:-ngocbinh123}"
PROJECT_NUMBER="${PROJECT_NUMBER:-2}"
MAX_WORKERS="${MAX_WORKERS:-3}"       # parallel claude -p sessions
MAX_COOK_WORKERS="${MAX_COOK_WORKERS:-1}" # cook cap: parallel test suites starve CPU
STALE_CLAIM_HOURS="${STALE_CLAIM_HOURS:-2}"
LOCK_DIR="${LOCK_DIR:-${TMPDIR:-/tmp}/ai-ticket-dispatcher.lock}"
# Headless permission allowlist: gh, git, file tools, test runner. Used only
# when BYPASS_PERMISSIONS=0. Space-separated tool specs.
CLAUDE_ALLOWED_TOOLS="${CLAUDE_ALLOWED_TOOLS:-Read Write Edit Glob Grep Bash(gh:*) Bash(git:*) Bash(node:*) Bash(npm:*) Bash(npx:*) Bash(bash:*) Bash(sh:*) Bash(mkdir:*) Bash(ls:*) Bash(cat:*)}"
# Unattended sessions cannot answer a permission prompt: a blocked tool call is
# silently dropped and the session drifts. Bypassing trades the prompt for the
# risk that a session runs any command in REPO_DIR. Set to 0 to re-arm prompts.
BYPASS_PERMISSIONS="${BYPASS_PERMISSIONS:-1}"
# /ck:vibe builds its worktree outside REPO_DIR; without --add-dir every tool
# call inside that worktree is rejected as an out-of-sandbox path.
CLAUDE_EXTRA_DIRS="${CLAUDE_EXTRA_DIRS:-$HOME/Documents/my-project/worktrees}"
# Wall-clock ceiling per claude -p session. A session that loses the API retries
# until it gives up (observed: 48 min) while holding its worker slot.
SESSION_TIMEOUT_SECS="${SESSION_TIMEOUT_SECS:-1800}"
# Session transcripts survive the cycle; WORK_DIR does not.
LOG_DIR="${LOG_DIR:-$HOME/.claude/logs/ai-ticket-dispatcher}"

DRY_RUN=0
[ "${1:-}" = "--dry-run" ] && DRY_RUN=1

# --------------------------------------------------------------- helpers ---
log() { printf '%s %s\n' "$(date -u +%FT%TZ)" "$*"; }
now_iso() { date -u +%FT%TZ; }
iso_to_epoch() { # BSD date (macOS)
  date -u -j -f "%Y-%m-%dT%H:%M:%SZ" "$1" +%s 2>/dev/null || echo 0
}
lc() { tr '[:upper:]' '[:lower:]'; }

# Every mutation goes through mut so --dry-run can print instead of execute.
mut() {
  if [ "$DRY_RUN" = 1 ]; then
    # stderr so callers' stdout redirects (>/dev/null) never swallow the plan
    log "DRY-RUN would: $*" >&2
  else
    "$@"
  fi
}

# ------------------------------------------------------------ cycle lock ---
if ! mkdir "$LOCK_DIR" 2>/dev/null; then
  prev_pid=$(cat "$LOCK_DIR/pid" 2>/dev/null || true)
  if [ -n "$prev_pid" ] && kill -0 "$prev_pid" 2>/dev/null; then
    log "previous cycle still running (pid $prev_pid) — exiting"
    exit 0
  fi
  log "removing stale lock (pid ${prev_pid:-unknown} is gone)"
  rm -rf "$LOCK_DIR"
  mkdir "$LOCK_DIR" || exit 1
fi
echo $$ >"$LOCK_DIR/pid"
WORK_DIR=$(mktemp -d "${TMPDIR:-/tmp}/ai-ticket-dispatcher.XXXXXX")
trap 'rm -rf "$LOCK_DIR" "$WORK_DIR"' EXIT

# Per-cycle transcript directory, kept after the cycle so failures stay debuggable.
CYCLE_LOG_DIR="$LOG_DIR/$(date -u +%Y%m%dT%H%M%SZ)"
mkdir -p "$CYCLE_LOG_DIR"

# -------------------------------------------------------- issue snapshot ---
ISSUES_JSON="$WORK_DIR/issues.json"
if ! gh issue list -R "$REPO" --state open -L 200 --json number,url,labels >"$ISSUES_JSON"; then
  log "ERROR: cannot list issues for $REPO"
  exit 1
fi

all_issue_numbers() { jq -r '.[].number' "$ISSUES_JSON"; }
issue_url() { jq -r --argjson n "$1" '.[] | select(.number == $n) | .url' "$ISSUES_JSON"; }
labels_of() { jq -r --argjson n "$1" '.[] | select(.number == $n) | .labels[].name' "$ISSUES_JSON" | lc; }
has_label() { labels_of "$1" | grep -qxF "$2"; }

# ------------------------------------------------------ pipeline labels ---
ensure_labels() {
  # idempotent; label colors: in-flight yellow, done green, kill-switch red
  local spec l c
  for spec in planning:fbca04 planned:0e8a16 cooking:fbca04 cooked:0e8a16 \
    reviewing:fbca04 reviewed:0e8a16 agent-ignore:d93f0b; do
    l=${spec%%:*}; c=${spec##*:}
    mut gh label create "$l" -R "$REPO" --color "$c" >/dev/null 2>&1 || true
  done
}

add_label() { mut gh issue edit "$1" -R "$REPO" --add-label "$2" >/dev/null; }
swap_label() { mut gh issue edit "$1" -R "$REPO" --remove-label "$2" --add-label "$3" >/dev/null; }
comment_issue() { mut gh issue comment "$1" -R "$REPO" --body "$2" >/dev/null; }
comment_pr() { mut gh pr comment "$1" -R "$REPO" --body "$2" >/dev/null; }

# ------------------------------------------------------ board operations ---
# Cache project id + Status field options on first use.
BOARD_META="$WORK_DIR/board-meta.json"
board_init() {
  [ -s "$BOARD_META" ] && return 0
  gh api graphql \
    -f query='query($login: String!, $number: Int!) {
      user(login: $login) { projectV2(number: $number) {
        id
        field(name: "Status") {
          ... on ProjectV2SingleSelectField { id options { id name } }
        }
      } }
    }' -f login="$PROJECT_OWNER" -F number="$PROJECT_NUMBER" \
    --jq '.data.user.projectV2' >"$BOARD_META" 2>/dev/null
}

board_move() { # <issue-number> <status-name>  e.g. board_move 12 "In review"
  board_init || { log "#$1: board_move failed (no board metadata)"; return 1; }
  local project_id field_id option_id item_id
  project_id=$(jq -r '.id' "$BOARD_META")
  field_id=$(jq -r '.field.id' "$BOARD_META")
  option_id=$(jq -r --arg s "$2" \
    '.field.options[] | select(.name | ascii_downcase == ($s | ascii_downcase)) | .id' \
    "$BOARD_META")
  item_id=$(gh api graphql \
    -f query='query($owner: String!, $repo: String!, $num: Int!) {
      repository(owner: $owner, name: $repo) { issue(number: $num) {
        projectItems(first: 20) { nodes { id project { id } } }
      } }
    }' -f owner="$OWNER" -f repo="$REPO_NAME" -F num="$1" \
    --jq ".data.repository.issue.projectItems.nodes[] | select(.project.id == \"$project_id\") | .id")
  if [ -z "$option_id" ] || [ -z "$item_id" ]; then
    log "#$1: board_move to '$2' failed (option='$option_id' item='$item_id')"
    return 1
  fi
  mut gh api graphql \
    -f query='mutation($p: ID!, $i: ID!, $f: ID!, $o: String!) {
      updateProjectV2ItemFieldValue(input: {
        projectId: $p, itemId: $i, fieldId: $f,
        value: { singleSelectOptionId: $o }
      }) { clientMutationId }
    }' -f p="$project_id" -f i="$item_id" -f f="$field_id" -f o="$option_id" >/dev/null
}

# The board is the single source of truth for Status. Reading it directly means
# no `status:*` label mirror has to exist, and no window where labels lag behind
# what a human sees on the board.
# Row: number<TAB>priority-rank<TAB>status (lowercased). Lower rank = higher prio.
BOARD_TSV="$WORK_DIR/board.tsv"
build_board_map() {
  gh api graphql --paginate \
    -f query='query($login: String!, $number: Int!, $endCursor: String) {
      user(login: $login) { projectV2(number: $number) {
        field(name: "Priority") {
          ... on ProjectV2SingleSelectField { options { id name } }
        }
        items(first: 100, after: $endCursor) {
          pageInfo { hasNextPage endCursor }
          nodes {
            prio: fieldValueByName(name: "Priority") {
              ... on ProjectV2ItemFieldSingleSelectValue { optionId }
            }
            status: fieldValueByName(name: "Status") {
              ... on ProjectV2ItemFieldSingleSelectValue { name }
            }
            content { ... on Issue { number state } }
          }
        }
      } }
    }' -f login="$PROJECT_OWNER" -F number="$PROJECT_NUMBER" 2>/dev/null |
    jq -r '.data.user.projectV2 as $p
      | ($p.field.options // [] | to_entries | map({(.value.id): .key}) | add // {}) as $rank
      | $p.items.nodes[]
      | select(.content.number != null and .content.state == "OPEN")
      | [.content.number,
         ($rank[.prio.optionId // ""] // 999),
         (.status.name // "" | ascii_downcase)]
      | @tsv' >"$BOARD_TSV" 2>/dev/null || : >"$BOARD_TSV"
}
prio_of() {
  local r
  r=$(awk -F'\t' -v n="$1" '$1 == n { print $2; exit }' "$BOARD_TSV" 2>/dev/null)
  echo "${r:-999}"
}
# Empty for an issue absent from the board, or in a column we do not act on
# (Backlog, Done, ...). The main loop's case statement drops those.
status_of() {
  awk -F'\t' -v n="$1" '$1 == n { print $3; exit }' "$BOARD_TSV" 2>/dev/null
}

# --------------------------------------------------------- PR discovery ---
prs_for_issue() { # JSON array of PRs referencing the issue (linked/closing)
  gh api graphql \
    -f query='query($owner: String!, $repo: String!, $num: Int!) {
      repository(owner: $owner, name: $repo) { issue(number: $num) {
        closedByPullRequestsReferences(first: 20, includeClosedPrs: true) {
          nodes { number url state createdAt mergedAt }
        }
      } }
    }' -f owner="$OWNER" -f repo="$REPO_NAME" -F num="$1" \
    --jq '.data.repository.issue.closedByPullRequestsReferences.nodes' 2>/dev/null || echo '[]'
}
latest_pr_for_issue() { # most recently created PR (JSON object or empty)
  prs_for_issue "$1" | jq -c 'sort_by(.createdAt) | last // empty'
}

# ---------------------------------------------- review-watch marker (§3) ---
# Marker = one PR comment whose entire body is:
#   <!-- ai-review-watch: last=2026-07-10T10:00:00Z -->
marker_info() { # <pr-number> -> "id<TAB>timestamp" or empty
  gh api "repos/$REPO/issues/$1/comments" --paginate \
    --jq '[.[] | select(.body | test("^<!-- ai-review-watch: last=[^ ]+ -->\\s*$"))]
          | last // empty | "\(.id)\t\(.body)"' 2>/dev/null |
    sed 's/<!-- ai-review-watch: last=\([^ ]*\) -->.*/\1/'
}
marker_set() { # <pr-number> <iso-timestamp> — edit in place, create if absent
  local id body
  id=$(marker_info "$1" | cut -f1)
  body="<!-- ai-review-watch: last=$2 -->"
  if [ -n "$id" ]; then
    mut gh api -X PATCH "repos/$REPO/issues/comments/$id" -f body="$body" >/dev/null
  else
    mut gh api "repos/$REPO/issues/$1/comments" -f body="$body" >/dev/null
  fi
}

# New activity since <last>: review comments, review bodies, issue comments.
new_pr_comments() { # <pr-number> <last-iso|empty> -> human-readable list
  local pr=$1 last=${2:-1970-01-01T00:00:00Z}
  {
    gh api "repos/$REPO/pulls/$pr/comments" --paginate --jq \
      ".[] | select(.created_at > \"$last\")
           | \"- \(.user.login) @ \(.created_at) (\(.html_url)):\n  \(.body)\"" 2>/dev/null
    gh api "repos/$REPO/pulls/$pr/reviews" --paginate --jq \
      ".[] | select((.submitted_at // \"\") > \"$last\" and .body != \"\")
           | \"- \(.user.login) @ \(.submitted_at) (review \(.state)) (\(.html_url)):\n  \(.body)\"" 2>/dev/null
    gh api "repos/$REPO/issues/$pr/comments" --paginate --jq \
      ".[] | select(.created_at > \"$last\")
           | select(.body | test(\"^<!-- ai-review-watch\") | not)
           | \"- \(.user.login) @ \(.created_at) (\(.html_url)):\n  \(.body)\"" 2>/dev/null
  }
}

ci_status_text() { # <pr-number> -> "green" | "red, failing: ..."
  local checks failing
  checks=$(gh pr checks "$1" -R "$REPO" --json name,state,link 2>/dev/null || true)
  [ -z "$checks" ] && { echo "green"; return; }
  failing=$(echo "$checks" | jq -r \
    '[.[] | select(.state == "FAILURE" or .state == "ERROR")]
     | map("\(.name) (\(.link))") | join("; ")' 2>/dev/null)
  if [ -n "$failing" ]; then echo "red, failing: $failing"; else echo "green"; fi
}

# ------------------------------------------- stale-claim recovery (§4) ----
label_added_at() { # <issue> <label> -> iso timestamp of last "labeled" event
  gh api "repos/$REPO/issues/$1/timeline" --paginate \
    --jq "[.[] | select(.event == \"labeled\" and ((.label.name // \"\") | ascii_downcase) == \"$2\")]
          | last // empty | .created_at" 2>/dev/null
}

stale_claim_recovery() {
  local n claim ts age_h
  for n in $(all_issue_numbers); do
    for claim in planning cooking reviewing; do
      has_label "$n" "$claim" || continue
      ts=$(label_added_at "$n" "$claim")
      [ -z "$ts" ] && continue
      age_h=$(( ($(date -u +%s) - $(iso_to_epoch "$ts")) / 3600 ))
      if [ "$age_h" -ge "$STALE_CLAIM_HOURS" ]; then
        log "#$n: stale claim '$claim' (${age_h}h) — adding agent-ignore"
        mut gh issue edit "$n" -R "$REPO" --remove-label "$claim" --add-label agent-ignore >/dev/null
        comment_issue "$n" "run interrupted (stale \`$claim\` claim after ${age_h}h), remove \`agent-ignore\` to retry"
      fi
    done
  done
}

# ------------------------------------------------------ claude sessions ---
# macOS ships no coreutils `timeout`. Poll the child, then escalate TERM -> KILL.
# Returns 124 on timeout, mirroring GNU timeout.
wait_with_timeout() { # <pid> <secs>
  local pid=$1 secs=$2 elapsed=0
  while kill -0 "$pid" 2>/dev/null; do
    if [ "$elapsed" -ge "$secs" ]; then
      kill -TERM "$pid" 2>/dev/null
      sleep 5
      kill -KILL "$pid" 2>/dev/null
      wait "$pid" 2>/dev/null
      return 124
    fi
    sleep 5
    elapsed=$((elapsed + 5))
  done
  wait "$pid"
}

run_claude() { # <prompt> — runs in the real codebase, bounded by SESSION_TIMEOUT_SECS
  local args=(-p "$1") tools=() d pid rc
  if [ "$BYPASS_PERMISSIONS" = 1 ]; then
    args+=(--dangerously-skip-permissions)
  else
    # read -a splits on spaces without glob-expanding specs like "Bash(gh:*)"
    read -r -a tools <<<"$CLAUDE_ALLOWED_TOOLS"
    args+=(--allowedTools "${tools[@]}")
  fi
  for d in $CLAUDE_EXTRA_DIRS; do
    [ -d "$d" ] && args+=(--add-dir "$d")
  done
  # exec makes the subshell BECOME claude, so the pid we time out is the real one.
  (cd "$REPO_DIR" && exec claude "${args[@]}") 2>&1 &
  pid=$!
  wait_with_timeout "$pid" "$SESSION_TIMEOUT_SECS"
  rc=$?
  [ "$rc" = 124 ] && log "session killed after ${SESSION_TIMEOUT_SECS}s timeout" >&2
  return "$rc"
}

run_brainstorm() { # <issue-number>
  local n=$1 url claim_ts prompt ok
  url=$(issue_url "$n")
  claim_ts=$(now_iso)
  prompt="/ck:brainstorm 'Analyze and clarify the requirement of issue #$n ($url).
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
2-3 candidate approaches with trade-offs; mark the recommended one and why.

## Open questions
Anything blocking implementation that needs a human answer (empty if none).

Post the FULL analysis (all sections above, not a summary) as ONE comment
on issue #$n, prefixed with the marker line <!-- ai-brainstorm -->.'"
  log "#$n: brainstorm session starting (log: $CYCLE_LOG_DIR/session-brainstorm-$n.log)"
  run_claude "$prompt" >"$CYCLE_LOG_DIR/session-brainstorm-$n.log" 2>&1
  # Success = a new <!-- ai-brainstorm --> comment exists (exit 0 is NOT enough).
  ok=$(gh api "repos/$REPO/issues/$n/comments" --paginate --jq \
    "[.[] | select(.created_at > \"$claim_ts\" and (.body | contains(\"<!-- ai-brainstorm -->\")))] | length" 2>/dev/null)
  if [ "${ok:-0}" -gt 0 ]; then
    swap_label "$n" planning planned
    log "#$n: brainstorm done — planning -> planned"
  else
    log "#$n: brainstorm produced no <!-- ai-brainstorm --> comment; leaving 'planning' for stale-claim recovery"
  fi
}

run_cook() { # <issue-number>
  local n=$1 url claim_ts prompt pr pr_url
  url=$(issue_url "$n")
  claim_ts=$(now_iso)
  prompt="/ck:vibe $url
Before planning, read the issue comments and locate the latest comment
marked <!-- ai-brainstorm -->. Treat it as the requirement contract:
implement the Goal within Scope, do NOT touch Out-of-scope items, write
the tests from the Verification (TDD) section first and make them the
pass/fail gate, and prefer the recommended approach from Ideas unless the
codebase contradicts it (if you deviate, say why in the PR description).
If no brainstorm comment exists, proceed from the issue body alone and
note that in the PR description."
  log "#$n: cook session starting (log: $CYCLE_LOG_DIR/session-cook-$n.log)"
  run_claude "$prompt" >"$CYCLE_LOG_DIR/session-cook-$n.log" 2>&1
  # Success = an OPEN PR referencing the issue, created after the claim.
  pr=$(prs_for_issue "$n" | jq -c \
    "[.[] | select(.state == \"OPEN\" and .createdAt > \"$claim_ts\")] | sort_by(.createdAt) | last // empty")
  if [ -n "$pr" ]; then
    pr_url=$(echo "$pr" | jq -r '.url')
    # Move to In review immediately (do not wait for CI green) + PR link.
    board_move "$n" "In review"
    comment_issue "$n" "PR ready for review: $pr_url"
    swap_label "$n" cooking cooked
    log "#$n: cook done — PR $pr_url, board -> In review, cooking -> cooked"
  else
    log "#$n: cook produced no open PR; leaving 'cooking' for stale-claim recovery"
  fi
}

run_review() { # <issue-number> <pr-number> <prompt-file>
  local n=$1 pr=$2 prompt_file=$3 out giveup
  log "#$n: review-fix session starting (PR #$pr)"
  out=$(run_claude "$(cat "$prompt_file")")
  echo "$out" >"$CYCLE_LOG_DIR/session-review-$n.log"
  giveup=$(echo "$out" | grep '^GIVE-UP:' | tail -1)
  if [ -n "$giveup" ]; then
    log "#$n: review session gave up — $giveup"
    add_label "$n" agent-ignore
    comment_issue "$n" "AI review-fix gave up after 3 CI-fix attempts on PR #$pr. $giveup — remove \`agent-ignore\` to resume after a human fix."
    comment_pr "$pr" "AI review-fix gave up after 3 CI-fix attempts. $giveup"
  fi
  # Always: bump marker to now, then reviewing -> reviewed (§3.4).
  marker_set "$pr" "$(now_iso)"
  swap_label "$n" reviewing reviewed
  log "#$n: review session finished — reviewing -> reviewed"
}

# ------------------------------------- review-watch cheap checks (§3.1-2) --
# Runs every cycle for board "In review" + cooked tickets, even when
# 'reviewed' is present. Appends expensive review sessions to the queue.
review_cheap_check() { # <issue-number> — may append to $QUEUE_FILE
  local n=$1 pr pr_num pr_url pr_state last comments ci prompt_file
  pr=$(latest_pr_for_issue "$n")
  [ -z "$pr" ] && { log "#$n: in review + cooked but no linked PR found — skipping"; return; }
  pr_num=$(echo "$pr" | jq -r '.number')
  pr_url=$(echo "$pr" | jq -r '.url')
  pr_state=$(echo "$pr" | jq -r '.state')

  case "$pr_state" in
  MERGED)
    log "#$n: PR #$pr_num merged — board -> Done"
    board_move "$n" "Done"
    comment_issue "$n" "merged in $pr_url"
    return
    ;;
  CLOSED)
    log "#$n: PR #$pr_num closed without merge — adding agent-ignore"
    add_label "$n" agent-ignore
    comment_issue "$n" "PR $pr_url was closed without merging; adding \`agent-ignore\`. Remove it (and \`reviewed\`) to re-run."
    return
    ;;
  esac

  # OPEN: session is one-shot — reviewing/reviewed blocks a new session.
  if has_label "$n" reviewing || has_label "$n" reviewed; then return; fi

  last=$(marker_info "$pr_num" | cut -f2)
  comments=$(new_pr_comments "$pr_num" "$last")
  ci=$(ci_status_text "$pr_num")
  if [ -z "$comments" ] && [ "$ci" = "green" ]; then
    return # nothing new — exit, 0 tokens
  fi

  prompt_file="$WORK_DIR/review-$n.prompt"
  cat >"$prompt_file" <<EOF
PR $pr_url for issue #$n. New review comments since ${last:-"(no marker — everything is new)"}:
${comments:-"(none)"}

CI status: $ci

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
Never force-push, never push to master, never merge the PR.
EOF
  # queue entry: statusRank|priority|issue|handler|extra
  echo "0|$(prio_of "$n")|$n|review|$pr_num|$prompt_file" >>"$QUEUE_FILE"
}

# ------------------------------------------------------------ main cycle ---
log "cycle start (dry-run=$DRY_RUN, repo=$REPO, max_workers=$MAX_WORKERS, max_cook=$MAX_COOK_WORKERS, bypass_perms=$BYPASS_PERMISSIONS, session_timeout=${SESSION_TIMEOUT_SECS}s)"
log "session logs: $CYCLE_LOG_DIR"
ensure_labels
build_board_map
log "board: $(grep -cE '	(ready|in progress|in review)$' "$BOARD_TSV" || true) issue(s) in Ready / In progress / In review"
stale_claim_recovery

# Re-snapshot claim labels after stale recovery may have changed them.
if [ "$DRY_RUN" = 0 ]; then
  gh issue list -R "$REPO" --state open -L 200 --json number,url,labels >"$ISSUES_JSON"
fi

QUEUE_FILE="$WORK_DIR/queue.txt"
: >"$QUEUE_FILE"

for n in $(all_issue_numbers); do
  # agent-ignore = global kill-switch: skip everything, even the merged check.
  has_label "$n" agent-ignore && continue
  status=$(status_of "$n")
  case "$status" in
  "ready")
    if ! has_label "$n" planning && ! has_label "$n" planned; then
      echo "2|$(prio_of "$n")|$n|brainstorm||" >>"$QUEUE_FILE"
    fi
    ;;
  "in progress")
    if ! has_label "$n" cooking && ! has_label "$n" cooked; then
      echo "1|$(prio_of "$n")|$n|cook||" >>"$QUEUE_FILE"
    fi
    ;;
  "in review")
    # Cheap checks run now (sequential, outside the pool); may queue a session.
    has_label "$n" cooked && review_cheap_check "$n"
    ;;
  esac
done

# Priority: In review -> In progress -> Ready; then board Priority; then FIFO.
sort -t'|' -k1,1n -k2,2n -k3,3n "$QUEUE_FILE" -o "$QUEUE_FILE"
queued=$(grep -c . "$QUEUE_FILE" || true)
log "queue: $queued ticket(s) needing a Claude session"

launched=0
cook_launched=0
pids=""
while IFS='|' read -r _rank _prio n handler extra1 extra2; do
  [ -z "$n" ] && continue
  if [ "$launched" -ge "$MAX_WORKERS" ]; then
    log "#$n: pool full — leftover stays queued by its labels for next cycle"
    continue
  fi
  if [ "$handler" = "cook" ] && [ "$cook_launched" -ge "$MAX_COOK_WORKERS" ]; then
    log "#$n: cook cap reached — stays queued for next cycle"
    continue
  fi

  # Claim BEFORE the session starts so overlapping cycles never double-run.
  case "$handler" in
  brainstorm) add_label "$n" planning ;;
  cook) add_label "$n" cooking ;;
  review) add_label "$n" reviewing ;;
  esac

  if [ "$DRY_RUN" = 1 ]; then
    log "DRY-RUN would run: $handler session for #$n ${extra1:+(PR #$extra1)}"
  else
    case "$handler" in
    brainstorm) run_brainstorm "$n" & ;;
    cook) run_cook "$n" & ;;
    review) run_review "$n" "$extra1" "$extra2" & ;;
    esac
    pids="$pids $!"
  fi
  launched=$((launched + 1))
  [ "$handler" = "cook" ] && cook_launched=$((cook_launched + 1))
done <"$QUEUE_FILE"

for pid in $pids; do wait "$pid"; done
log "cycle end (launched=$launched)"
