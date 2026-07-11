# Changelog — bi-git

## 0.1.0 — 2026-07-05

- Initial release with three skills: `bi-commit-convention`, `bi-rebase-conflict`,
  `bi-pr-workflow`.

## 0.2.0 — 2026-07-11

- New skill `bi-git-create-ticket`: create GitHub tickets or sub-issues with a
  structured description template (expectation / goal / scope / acceptance
  criteria), required metadata interview (assignee, project, one of six labels,
  priority defaulting to `normal`), and two-way parent linking via the GraphQL
  `addSubIssue` mutation with a documented fallback.
