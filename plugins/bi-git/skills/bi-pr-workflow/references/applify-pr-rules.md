# Applify PR rules — embedded template + fill rules

Source of truth for Applify PR descriptions. This template ALWAYS wins, even
over a repo's own `.github/PULL_REQUEST_TEMPLATE*`.

Keep the description short and ticket-focused. The PR body is a reviewer aid,
not a design doc — the diff carries the detail.

## Embedded template

```markdown
## Summary

<!-- 1–3 sentences: the behavior this PR ships. -->

Closes #<!-- issue --> / Refs #<!-- parent issue -->

## Scope of this PR

<!-- Key classes/files or scenarios touched. What is NOT in this PR.
     Do not mix features/bugfixes with unrelated reformat, refactor, or
     cleanup (POL-ENG-004). -->

## Acceptance criteria

<!-- Copied verbatim from the ticket. -->

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
```

## Fill rules per section

| Section | Rule |
|---|---|
| Summary + Closes/Refs | 1–3 sentences on the behavior shipped — no paragraph-by-paragraph implementation walkthrough. `Closes #N` when the PR completes the issue; `Refs #N` for a partial slice of a multi-PR parent. |
| Scope of this PR | Name only the key classes/files or scenarios affected (e.g. `FirebaseService`, `ApiManager`); state what is OUT of scope. Do not enumerate every changed line. |
| Acceptance criteria | Copy verbatim from the ticket — do not reword or re-derive. If the PR is a partial slice, copy the subset it satisfies. |
| Test plan | Focus on happy cases + common edge cases. ASK the user for the item list AND the verified/not-verified status of each item; tick checkboxes only per their answers. |
| Unit/integration tests pass | Auto-tick ONLY because the validate gate really ran the tests in this session; write the exact command into the line (e.g. `npm test`). Never tick from memory or assumption. |
| Links — Spec | Link the spec when one exists. |
| Links — Redmine | Skip — leave empty. |
| Screenshots / recordings | Mandatory reminder whenever the diff touches UI; before/after for visual changes. |
| Migration / deployment notes | React / React Native project → write "None" directly, do NOT ask the user (keep the section, do not delete it). Backend project only → ask the user (DB migrations, flags, Kafka schemas). |

## Reviewers

Do NOT add a Reviewers section, a Reviewer notes section, or auto-request any
reviewers. Reviewer assignment is handled outside this skill (repo settings /
the human opening the PR). Do not run `gh pr create --reviewer ...`.
