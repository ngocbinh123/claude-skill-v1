# Changelog — bi-git

## 0.1.2 — 2026-07-10

- New skill `bi-git-workflow`: param-routed `cp` (stage → layered secret
  scan → conventional commit with ticket id → push) and `pr` (cp path →
  remote-diff PR → template fill → PR link commented on the ticket +
  Development-section branch link). Branch guard covers main/master, the
  repo's default branch, protected patterns, and detached HEAD. Host
  projects override conventions via their declared git rules; safety gates
  are non-overridable. Version set to 0.1.2 by owner decision (issue #6).

## 0.1.0 — 2026-07-05

- Initial release with three skills: `bi-commit-convention`, `bi-rebase-conflict`,
  `bi-pr-workflow`.
