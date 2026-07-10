# Project overview — declarations

Single declarative source of project facts for humans, Claude sessions, and
skills. **Values live here; rules live in their native homes (linked).**
Never copy rule content into this file — update the native home instead.

## Identity

- **Name:** claude-skill-v1
- **Type:** library — monorepo of Claude Code plugins (Agent Skills standard)
- **Tech stack:** Markdown skills + Node.js tooling (`tools/`), GitHub Actions CI
- **Purpose & scope:** [goals.md](goals.md)

## Management

- **Board:** <https://github.com/users/ngocbinh123/projects/2/views/1>
- **Ticket title prefix:** `[ClaudeSkillV1]`
- **Ticket lifecycle & label conventions** (`status:*`, `planning/planned`,
  `cooking/cooked`, `reviewing/reviewed`, `agent-ignore`):
  [ticket-automation.md](ticket-automation.md)

## Architecture

- **Style:** 5-layer monorepo with a one-way dependency rule
  (Content → Packaging → Distribution → Quality → Tooling)
- **Structure, dependency rule & decision log:** [architecture.md](architecture.md)

## Patterns

- **Skills are built test-first:** eval scenarios before SKILL.md —
  [../evals/README.md](../evals/README.md)
- **Authoring style & checklists:** [authoring.md](authoring.md)
- **Hard rules & quality gates:** [governance.md](governance.md)

## Git rules

- **Default branch:** `master` — stable release channel; develop on branches,
  merge only release-ready work (see [../CLAUDE.md](../CLAUDE.md))
- **Branch naming:** `<type>/<issue>-<slug>` (e.g. `feat/3-project-overview-declarations`)
- **Commit convention:** Conventional Commits (`feat:`, `fix:`, `docs:`, …),
  no AI references
- **Merge strategy:** PR into `master` behind the two-step CI gate;
  contribution workflow: [governance.md](governance.md)
- **PR template:** [../.github/PULL_REQUEST_TEMPLATE.md](../.github/PULL_REQUEST_TEMPLATE.md)
- **Version & release policy:** [versioning.md](versioning.md)

## Design

- N/A — library-type repo (no UI). Design declarations apply to mobile/web
  projects only.

## Quality

- **Static gates (run before committing):**
  `node tools/lint-frontmatter.js && node tools/check-governance.js && node tools/sync-versions.js --check`
- **Behavioral evals:** `node tools/run-evals.js --plugin <name>` —
  [../evals/README.md](../evals/README.md)
- **CI:** `.github/workflows/validate.yml` + `.github/workflows/skill-evals.yml`
