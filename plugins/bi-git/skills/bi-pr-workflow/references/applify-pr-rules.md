# Applify PR rules — embedded template + fill rules

Source of truth for Applify PR descriptions. This template ALWAYS wins, even
over a repo's own `.github/PULL_REQUEST_TEMPLATE*`.

> Maintenance note: reviewer usernames and template structure are hardcoded
> here by team decision — changing them requires a new plugin release.

## Embedded template

```markdown
## Summary

<!-- What changed and why (2–5 sentences). -->

Closes #<!-- issue --> / Refs #<!-- parent issue -->

## Scope of this PR

<!-- Which subtask(s) this covers. What is NOT in this PR.
     Do not mix features/bugfixes with unrelated reformat, refactor, or
     cleanup (POL-ENG-004). -->

## Acceptance criteria

- [ ]
- [ ]

## Test plan

- [ ] Unit/integration tests pass (`<command>`)
- [ ] Manual verification: <!-- describe -->

## Links

- **Spec:** <!-- link if applicable -->
- **Redmine:** <!-- leave empty -->

## Screenshots / recordings

<!-- For UI changes. -->

## Migration / deployment notes

<!-- Backend only. Write "None" for React / React Native projects. -->

## Reviewers

**Release accountable reviewer:** @<!-- RAR — user fills; must not be author -->

**Contributing reviewers (optional):** @tomislav-t @briansonnguyen

## Reviewer notes

<!-- leave empty -->
```

## Fill rules per section

| Section | Rule |
|---|---|
| Summary + Closes/Refs | Derive from the diff and the ticket. `Closes #N` when the PR completes the issue; `Refs #N` for a partial slice of a multi-PR parent. |
| Scope of this PR | Derive from the diff; explicitly name what is OUT of scope. |
| Acceptance criteria | Only the subset this PR satisfies — take from the issue or ask the user. |
| Test plan | Focus on happy cases + common edge cases. ASK the user for the item list AND the verified/not-verified status of each item; tick checkboxes only per their answers. |
| Unit/integration tests pass | Auto-tick ONLY because the validate gate really ran the tests in this session; write the exact command into the line (e.g. `npm test`). Never tick from memory or assumption. |
| Links — Spec | Link the spec when one exists. |
| Links — Redmine | Skip — leave empty. |
| Screenshots / recordings | Mandatory reminder whenever the diff touches UI; before/after for visual changes. |
| Migration / deployment notes | React / React Native project → write "None" directly, do NOT ask the user (keep the section, do not delete it). Backend project only → ask the user (DB migrations, flags, Kafka schemas). |
| Reviewers | See below. |
| Reviewer notes | Skip — leave empty. |

## Reviewers

Add both default reviewers on the PR itself:

```bash
gh pr create ... --reviewer tomislav-t --reviewer briansonnguyen
```

- The **RAR line in the body is left for the user** — exactly one RAR per
  Applify policy, never the PR author. Do not guess who the RAR is.
- If the reviewer add fails (no repo access, bad username): report the exact
  error once, keep the PR, tell the user to assign reviewers manually. Do
  NOT retry-loop and do NOT abort the PR because of it.
