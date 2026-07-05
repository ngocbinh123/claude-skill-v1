# claude-skill-v1 — contributor guide

Monorepo of Claude Code plugins (skills for Git, React Native, Android, iOS).
Marketplace manifest: `.claude-plugin/marketplace.json`.

Foundational docs (read before structural changes): `docs/README.md` —
goals, architecture + decision log, versioning, governance, roadmap.

## Architecture (dependency rule: outer depends on inner, never reverse)

1. **Content** — `plugins/*/skills/*/` SKILL.md + references/ + scripts/.
   Pure Agent Skills standard; knows nothing about packaging.
2. **Packaging** — `plugins/*/.claude-plugin/plugin.json`. Semver lives HERE
   (single source of truth).
3. **Distribution** — `.claude-plugin/marketplace.json`. Versions are synced
   FROM plugin.json by `node tools/sync-versions.js` — never edit versions
   here by hand.
4. **Quality** — `evals/<plugin>/<skill>/scenarios.md`. Skills are built
   test-first (see `evals/README.md`).
5. **Tooling** — `tools/`, `.github/workflows/validate.yml`.

## Hard rules

- New/changed skill ⇒ scenarios in `evals/` first (TDD), then SKILL.md.
- Frontmatter: exactly `name` + `description`; description must contain a
  "Use when ..." trigger phrase. Lint: `node tools/lint-frontmatter.js`.
- SKILL.md body ≤ 500 lines; depth goes to `references/`.
- Version bump: edit plugin.json only, then run `node tools/sync-versions.js`.
- `main` is the stable release channel (community marketplace tracks its
  HEAD). Develop on branches; merge only release-ready work.
- Style guide: `docs/authoring.md`. Template: `docs/skill-template/SKILL.md`.
- Full rule set + quality gates: `docs/governance.md`. Version/release
  policy: `docs/versioning.md`.

## Verify before committing

```bash
node tools/lint-frontmatter.js && node tools/sync-versions.js --check
```
