# Versioning & Releases

## Semver per plugin

Each plugin versions independently. `plugins/<name>/.claude-plugin/plugin.json`
is the **single source of truth**; `.claude-plugin/marketplace.json` is
derived from it by `node tools/sync-versions.js` and guarded by CI
(`sync-versions.js --check`). Never edit versions in marketplace.json by hand.

| Bump | When |
|---|---|
| **patch** (0.1.0 → 0.1.1) | Wording fixes, reference-file updates, description tuning that doesn't change triggers, bug fixes in scripts |
| **minor** (0.1.0 → 0.2.0) | New skill added, new reference/script capability, materially expanded workflow, description trigger changes |
| **major** (0.x → 1.0, 1.x → 2.0) | Skill removed or renamed, workflow philosophy reversed, anything that invalidates how existing users/docs refer to the plugin |

Pre-1.0 caveat: while plugins are `0.x`, minor bumps may include breaking
changes; `1.0.0` for a plugin means its skill set and names are stable.

The marketplace itself has `metadata.version` — bump minor when plugins are
added/removed from the catalog, patch for metadata-only edits.

## Branch strategy

- **The default branch (`master` in this repo) = stable release channel.**
  Users' installs and (later) the community marketplace's daily SHA-bump
  sweep track its HEAD. Nothing lands on it unless it is release-ready and
  CI-green. (Docs elsewhere say `main` generically — read it as "the
  default branch".)
- All work happens on feature branches; merging to the default branch is
  the release act.

## Release procedure

1. Finish work on a branch; evals GREEN for touched skills.
2. Bump `version` in each touched plugin's `plugin.json`.
3. `node tools/sync-versions.js` (updates marketplace.json).
4. Update the plugin's `CHANGELOG.md` (date + human-readable changes).
5. Verify: `node tools/lint-frontmatter.js && node tools/sync-versions.js --check`
   and `claude plugin validate` on touched plugins.
6. Merge to `main`. Tag releases `<plugin>-v<version>` (e.g.
   `bi-git-v0.2.0`) so plugin histories are navigable in one repo.

## How updates reach users

| Channel | Mechanism | Latency |
|---|---|---|
| Self-hosted marketplace | Client refresh: startup auto-update (user must enable it once for third-party marketplaces — README instructs this) or `/plugin marketplace update bi-skills` | Immediate on refresh |
| `anthropics/claude-plugins-community` (after acceptance) | Their daily sweep re-validates our new `main` HEAD and auto-bumps the SHA pin — no re-submission, no manual action | ~1–3 days |
| `npx skills add` users | Files are copied at install time; users must re-run the installer's update command | Manual |

Consequence of the community sweep tracking `main`: **never merge
work-in-progress to `main`** — it can be swept into the official catalog
within a day.

## Version support policy

Only the latest version of each plugin is supported. No backports — skills
are documentation-weight artifacts; users on old versions upgrade by
updating, not by receiving patches to old lines.
