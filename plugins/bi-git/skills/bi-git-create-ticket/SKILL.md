---
name: bi-git-create-ticket
description: Create GitHub tickets or sub-issues with a structured description template (expectation, goal, scope, acceptance criteria) and required metadata collected up front. Use when creating a ticket, creating an issue, filing a bug, adding a task, or creating a sub-issue/sub-ticket of a parent issue.
---

# Create Ticket / Sub-issue

## Overview

A ticket is a contract, not a reminder. Never create an issue whose body is
empty or one line: interview for what's missing, build the body from the
template in `references/ticket-template.md`, confirm, then create via `gh`.

**Scope:** issue creation only. PR work belongs to `bi-pr-workflow`; issue
editing and board column automation are out of scope.

## 1. Interview — collect required inputs

Collect ALL of these before creating. Ask only for what the conversation has
not already provided; batch the questions in one round, don't drip-feed.

| Input | Rule |
|---|---|
| Title | Short, imperative; drafted from the request, confirmed by user |
| Description content | Enough to fill Expectation / Goal / Scope / Acceptance Criteria |
| Assignee | Always ask — never assume or hardcode |
| Project | Board name; resolve to a number via `gh project list` (see references). Ask only when zero or multiple matches |
| Label | Exactly ONE of: `skill`, `backend`, `frontend`, `bug`, `research`, `document` |
| Priority | Default `normal` when unmentioned — do NOT ask an extra question for it |
| Parent issue | Optional; capture the number when the user says sub-ticket/sub-issue/child of #N |

When the user asks for a label outside the six, do not invent it: name the
closest allowed match(es) and let the user pick.

The target repo is inferred from the CWD's `git remote` (`gh repo view`);
ask only when there is no remote or the user names a different repo.

## 2. Build the body

Fill the template from `references/ticket-template.md`: `## Expectation`,
`## Goal`, `## Scope` (In/Out), `## Acceptance Criteria` (one checkbox per
criterion), a `Priority: <value>` line, and `## Parent Ticket` when a parent
was given.

If the user gives only a one-liner ("just fix it"), expand it into a full
draft from the surrounding context yourself — state that a one-line ticket
can't be planned or reviewed — and show the draft for confirmation. Refusing
to structure is not an option; creating unstructured is not either.

## 3. Confirm, then create

Show the final title + body and get a go-ahead, then:

```bash
gh issue create \
  --title "<title>" \
  --body-file <(printf '%s' "$BODY") \
  --assignee "<assignee>" \
  --label "<label>"
```

Attach the project (`--project "<name>"` on create, or
`gh issue edit <number> --add-project "<name>"` after). If a label or project
does not exist in the repo, report the exact `gh` error and suggest the fix —
do not create labels/projects yourself.

## 4. Link the parent (sub-issues only)

When a parent was captured, create the native sub-issue relationship with the
GraphQL `addSubIssue` mutation — exact recipe in
`references/ticket-template.md`. If the mutation is unavailable, use the
documented fallback: `## Parent Ticket` section in the child body plus a
`Sub-task created: #<child>` comment on the parent. Always report which
mechanism linked the issues.

## 5. Report

Return: issue URL, title, assignee, project, label, priority, and the parent
link (with mechanism) when applicable.

## Anti-patterns

- Do NOT create a ticket with an empty or one-line body, even when told
  "create now, no questions" — draft the structured body first and confirm.
- Do NOT invent labels outside the fixed six or turn priority into a label.
- Do NOT hardcode assignees, repos, or title prefixes — everything comes from
  the interview or the CWD's git remote.
- Do NOT open PRs, edit existing issues, or move board columns from this
  skill — hand off to `bi-pr-workflow` or state the boundary.
- Do NOT skip the parent link because GraphQL failed — apply the fallback and
  say so.
