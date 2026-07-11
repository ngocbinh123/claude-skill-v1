# cp — commit and push

Runs after the shared pre-flight in SKILL.md (branch guard passed, git rules
resolved, ticket id known).

## 1. Stage

```bash
git add -A
git diff --cached --stat
```

## 2. Layered secret scan — STOP on any hit

**2a. Staged-path denylist.** Check file paths first — some files should
never be committed regardless of content:

```bash
git diff --cached --name-only | grep -iE '(^|/)(\.env[^/]*|.*\.pem|.*\.p12|.*\.key|id_rsa[^/]*|.*credentials.*|.*\.keystore|service-account.*\.json)$'
```

On match: unstage the file (`git restore --staged <file>`), suggest adding it
to `.gitignore`, and ask the user before continuing. (`.env.example` /
`.env.*.example` templates are the exception — placeholders, not values.)

**2b. Content scan on ADDED lines only** (scanning the whole diff false-
positives on removed lines and on prose that merely mentions "token"):

```bash
git diff --cached | grep '^+' | grep -iE "(api[_-]?key|token|password|secret|credential|AKIA[0-9A-Z]{16}|-----BEGIN .*PRIVATE KEY|ghp_[A-Za-z0-9]{20,}|github_pat_|sk_live_|xox[bp]-|(mongodb|postgres|mysql|redis)://[^ ]*:[^ ]*@)"
```

**2c. Binary files.** `git diff --cached` shows binaries as
`Binary files differ` — their content is NOT scanned. A staged binary
(keystore, db, archive) needs explicit user confirmation before commit.

**On any hit:**

1. STOP — no commit, no push.
2. Report file + line location only; MASK the value (`sk_live_51H…` → first
   8 chars + ellipsis). Never echo the full secret back anywhere.
3. Distinguish a value assignment (`KEY=sk-...` — block) from a prose
   mention (docs discussing "API keys" — may proceed with user confirmation).
4. Wait for the user's decision. If a real secret was staged, recommend
   rotating it — it may already be exposed locally.

## 3. Split decision

Apply the split-commit criteria from the resolved git rules (default:
`references/git-rules.md`). When splitting, stage and commit each group
separately (`git restore --staged .` then `git add <group>` per commit).

## 4. Commit

Message per the resolved commit convention, always containing the ticket id,
never containing AI references:

```bash
git commit -m "feat(scope): subject (#6)"
```

## 5. Push — with outgoing-range scan

The staged-diff scan (step 2) only covers what was staged NOW. Commits made
earlier outside this workflow may also be about to leave the machine, so scan
the full outgoing range before pushing:

```bash
BASE=$(gh repo view --json defaultBranchRef --jq .defaultBranchRef.name 2>/dev/null) ||
  BASE=$(git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null | sed 's|^origin/||')
[ -n "$BASE" ] || { echo "STOP: cannot resolve base branch"; exit 1; }
git fetch origin || { echo "STOP: fetch failed — refs may be stale"; exit 1; }
git diff origin/$BASE...HEAD 2>/dev/null | grep '^+' | grep -iE "(api[_-]?key|token|password|secret|credential|AKIA[0-9A-Z]{16}|-----BEGIN .*PRIVATE KEY|ghp_[A-Za-z0-9]{20,}|github_pat_|sk_live_|xox[bp]-|(mongodb|postgres|mysql|redis)://[^ ]*:[^ ]*@)"
```

Fail closed: if the base branch cannot be resolved (works without `gh` via the
remote-HEAD fallback) or `git fetch origin` fails, ABORT — a scan against
stale refs can report a false clean result. The content regex is the SAME
complete pattern as step 2b; never use a reduced pattern here.

(First push of a new branch: diff against `origin/$BASE` alone.) On a hit:
STOP and report as in step 2 — a secret in an earlier commit needs history
surgery, not just an unstage.

Then:

```bash
git push -u origin "$(git branch --show-current)"
```

## Output summary

```
✓ staged: N files (+X/-Y)
✓ secret scan: paths ok, content ok, outgoing range ok
✓ commit(s): <hash> type(scope): subject (#id)
✓ pushed: origin/<branch> (upstream set)
```

## Errors

| Error | Action |
|-------|--------|
| Push rejected (non-fast-forward) | `git pull --rebase`, resolve conflicts, RE-RUN the step-5 outgoing-range scan (the rebase may have changed outgoing content), then push — never `--force` |
| No remote `origin` | Ask the user which remote to use |
| Nothing to commit | Report clean tree, exit |
