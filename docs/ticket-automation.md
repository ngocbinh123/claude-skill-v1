# Ticket status automation

Workflow: `.github/workflows/ticket-status-automation.yml`
Prompts: `.github/prompts/ticket-clarify.md`, `.github/prompts/ticket-plan.md`

When a ticket on the project board
(<https://github.com/users/ngocbinh123/projects/2>) changes Status, an AI
pass runs and comments on the issue:

| Transition          | What happens                                                                                                                                                                    |
| ------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `backlog → ready`   | AI judges whether the requirement is clear. **Clear** → posts a "✅ Requirement RECAP" comment (summary, scope, out of scope, acceptance criteria, risks) and labels the issue `requirement:clear`. **Not clear** → posts open questions + suggested next action and labels `requirement:needs-clarification`. |
| `ready → develop`   | AI posts "🛠️ Implementation suggestions & test cases": recommended approach, alternatives, step checklist, test-case table, risks.                                              |

## How detection works (and why it polls)

GitHub Actions has **no trigger for Projects v2 field changes** — the
`projects_v2_item` webhook is not exposed to repository workflows, and
user-owned projects can't install webhooks at all. So the workflow:

1. Runs on a schedule (every 15 minutes) and on manual dispatch.
2. Reads all board items via the GraphQL API.
3. Mirrors each issue's Status into a `status:<value>` label on the issue.
4. A difference between the label (last seen) and the board (current) is a
   transition. The label is updated first, so each transition fires **at most
   once** even if the AI step fails.

Consequences to be aware of:

- Up to ~15 minutes of delay between moving a card and the comment.
- The first run only records a baseline label for every ticket — no comments.
- If a ticket jumps two columns between polls (e.g. `backlog → develop`),
  the intermediate transition is not seen and no rule matches.
- Only issues in **this repository** are processed; items from other repos on
  the same board are ignored.
- Don't remove or hand-edit `status:*` labels — they are the workflow's memory.

## Required setup

1. **`PROJECT_TOKEN` repository secret** — the default `GITHUB_TOKEN` cannot
   read Projects v2. Create a PAT for `ngocbinh123`:
   - Classic PAT: scopes `project` (read) + `repo`, or
   - Fine-grained PAT: *Projects: read* (account) + *Issues: read/write* on
     this repo.

   Add it under *Settings → Secrets and variables → Actions →
   `PROJECT_TOKEN`*.
2. **GitHub Models access** — the AI steps use
   [`actions/ai-inference`](https://github.com/actions/ai-inference) with the
   built-in `GITHUB_TOKEN` (`models: read` permission). GitHub Models must be
   enabled for the account/repo (Settings → Models). Copilot Chat itself is
   not scriptable from Actions; GitHub Models is the supported equivalent.
3. **Board Status options** must include `Backlog`, `Ready`, `Develop`
   (case-insensitive). Different names or extra transitions? Edit
   `TRANSITION_RULES` in the workflow `env` block, one rule per line:

   ```text
   backlog->ready=clarify
   ready->develop=plan
   ready->in progress=plan   # example: alternative column name
   ```

## Manual runs & testing

*Actions → ticket-status-automation → Run workflow* with:

- `issue_number` + `action=clarify|plan` — runs that handler on one issue
  directly, skipping the board scan (also works without `PROJECT_TOKEN`).
- no inputs — forces an immediate board scan.

To re-run clarification after answering questions, move the ticket back to
`backlog` and then to `ready` again (the label mirror follows both moves).

## Labels used

| Label                             | Meaning                                     |
| --------------------------------- | ------------------------------------------- |
| `status:<value>`                  | Last board Status seen by the poller        |
| `requirement:clear`               | Clarification verdict: ready to plan        |
| `requirement:needs-clarification` | Open questions posted; needs product input  |
