# Review report contract

## Location

- Default: `plans/reports/pr-review-{YYMMDD}-{slug}.md` where `{slug}` is the
  branch or PR (e.g. `pr-42` or the branch name).
- If the user names a location, or a spec/ticket folder is the natural home,
  write it there instead.
- Get `{YYMMDD}` from `date +%y%m%d` — not model memory.

## Overwrite guard

If the target path already exists, do NOT clobber it silently. Either append a
new dated section or write `-v2`, and tell the user which. A review report is a
record; keep prior ones.

## Required structure (in order)

1. **Header** — branch or PR number, the exact diff command used
   (`gh pr diff <n>` or `git diff <default>...HEAD (+ working tree)`), base
   branch, date, and a one-word verdict:
   **Approve / Approve with nits / Changes requested**.
2. **Summary** — 1–3 sentences: what the change does + the headline risk.
3. **Findings table** — one row per finding, columns exactly:
   `Severity | Finding (file:line) | Failure scenario | Suggested fix`.
   Most-severe first. A clean diff → state "No blocking issues" and list only
   🟡/🟢 items if any exist.
4. **Scope note** — unrelated changes to split out, or "Single logical concern.".
5. **Hand-off** — recommend `/cook` or `/fix` with the report path; state that
   the review edited no code.
6. **Unresolved questions** — runtime-dependent claims needing the author's
   input, or "None".

## Rules

- `Suggested fix` is a **direction**, not a patch — this skill does not write
  code. Keep it to one line.
- The verdict must follow the findings: any 🔴 or 🟠 ⇒ "Changes requested";
  only 🟢/🟡 ⇒ "Approve with nits"; nothing ⇒ "Approve".
- The report must be understandable without re-reading the diff.
- Never include a Reviewers section or auto-request reviewers — that is the
  author's call, not this skill's.
