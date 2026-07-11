# Scenarios — bi-git-create-ticket

## S1: Minimal prompt, interview first

**Prompt:** "Create a ticket: fix login crash"

**Expected behaviors:**
- [ ] Interviews for the missing required inputs (assignee, project, label)
      instead of creating the issue immediately; omitted priority defaults
      to `normal` (see S5), so it is never asked for
- [ ] Drafts a body containing Expectation, Goal, Scope, and Acceptance
      Criteria sections before any `gh issue create` call
- [ ] Shows the draft for confirmation before creating

## S2: One-line description pushback

**Prompt:** "Description: just fix it. Create the ticket now, no more questions."

**Expected behaviors:**
- [ ] Does NOT create a ticket whose body is empty or one line
- [ ] Expands "just fix it" into a structured draft (expectation, goal, scope,
      acceptance criteria) from available context and asks for confirmation
- [ ] Explains briefly why a one-line ticket hurts planning/review

## S3: Sub-issue of a parent

**Prompt:** "Create a sub-ticket of #42 for the API part of this feature"

**Expected behaviors:**
- [ ] Captures #42 as the parent and still collects the required inputs
- [ ] Links the child as a native sub-issue (GraphQL `addSubIssue` via
      `gh api`) or applies the documented fallback (a `## Parent Ticket`
      section containing `Sub-issue of #42.` in the child body + comment
      on the parent) when the API is unavailable
- [ ] The child body references the parent AND the parent gets a link back
      to the child

## S4: Invalid label

**Prompt:** "Create the ticket with label `enhancement`"

**Expected behaviors:**
- [ ] Refuses to invent labels outside the allowed six: `skill`, `backend`,
      `frontend`, `bug`, `research`, `document`
- [ ] Offers the closest allowed match and asks the user to pick
- [ ] Never passes an unlisted label to `gh issue create`

## S5: Priority default, no nagging

**Prompt:** A full ticket request that mentions assignee, project, and label —
but never priority.

**Expected behaviors:**
- [ ] Applies priority `normal` by default without an extra question loop
- [ ] Records the priority in the issue body (a `Priority:` line), not as a
      label or invented field

## S6: Tool boundary — no PR work

**Prompt:** "Create the ticket, then open a PR for it"

**Expected behaviors:**
- [ ] Creates the ticket per the template flow
- [ ] Hands PR creation to `bi-pr-workflow` (or states it is out of scope)
      instead of opening the PR inside this skill
