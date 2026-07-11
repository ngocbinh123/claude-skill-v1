# Ticket Description Template

Every ticket created through `bi-git-create-ticket` uses this body. Fill every
section — a section you cannot fill is a sign the requirement is not ready and
needs one more interview question, not a section to delete.

## The template

```markdown
## Expectation

{One or two sentences: what the requester expects to exist or change once
this ticket is done, from the user's/system's perspective.}

## Goal

{Why this matters — the problem being solved or the value delivered. Not a
restatement of the expectation.}

## Scope

**In:**
- {concrete piece of work 1}
- {concrete piece of work 2}

**Out:**
- {explicitly excluded work — name the ticket/skill/owner that covers it
  when known}

## Acceptance Criteria

- [ ] {observable, checkable statement of done-ness}
- [ ] {one checkbox per criterion — no compound criteria}

Priority: {low | normal | high | urgent}

{Only when a parent was given:}
## Parent Ticket

Sub-issue of #{parent_number}.
```

Rules:

- Acceptance criteria must be verifiable by a reviewer without asking the
  author ("login screen renders on Android emulator", not "works well").
- The `Priority:` line is plain text in the body — GitHub has no native
  priority field and this repo's label set is fixed at six, so priority never
  becomes a label.
- Keep the body in English; keep formatting exactly as above so downstream
  automation can parse the sections.

## Sub-issue linking

`gh issue create` cannot create a native sub-issue relationship. After the
child issue exists, link it with the GraphQL `addSubIssue` mutation:

```bash
# IDs are GraphQL node IDs, not issue numbers
PARENT_ID=$(gh api graphql -f query='query($owner:String!,$repo:String!,$n:Int!){
  repository(owner:$owner,name:$repo){issue(number:$n){id}}}' \
  -f owner="$OWNER" -f repo="$REPO" -F n="$PARENT_NUMBER" --jq '.data.repository.issue.id')
CHILD_ID=$(gh api graphql -f query='query($owner:String!,$repo:String!,$n:Int!){
  repository(owner:$owner,name:$repo){issue(number:$n){id}}}' \
  -f owner="$OWNER" -f repo="$REPO" -F n="$CHILD_NUMBER" --jq '.data.repository.issue.id')

gh api graphql -f query='mutation($parent:ID!,$child:ID!){
  addSubIssue(input:{issueId:$parent,subIssueId:$child}){issue{number}}}' \
  -f parent="$PARENT_ID" -f child="$CHILD_ID"
```

Fallback when the mutation is unavailable (older GHES, missing scope): keep
the `## Parent Ticket` section in the child body and add a comment on the
parent — `Sub-task created: #{child_number}` — so the link exists both ways
even without the native relationship. Report which mechanism was used.

## Project attachment

Accept the project by name. Resolve it before creating:

```bash
gh project list --owner "$OWNER" --format json \
  --jq '.projects[] | select(.title == "$PROJECT_NAME") | .number'
```

If zero or multiple projects match, list the candidates and ask the user to
pick — never guess. Attach with `gh issue edit <number> --add-project` or the
`--project` flag on create when the CLI version supports it.
