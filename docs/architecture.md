# Architecture

A monorepo organized as five layers with a one-way dependency rule, modeled
on the strongest patterns found in a 2026-07 dissection of the leading
skill/plugin repos (obra/superpowers, anthropics/skills, wshobson/agents,
anthropics/claude-plugins-official).

## The five layers

```
┌────────────────────────────────────────────────────────────┐
│ 5  TOOLING & GOVERNANCE   tools/  .github/workflows/  docs/ │
├────────────────────────────────────────────────────────────┤
│ 4  QUALITY                evals/<plugin>/<skill>/           │
├────────────────────────────────────────────────────────────┤
│ 1  DISTRIBUTION           .claude-plugin/marketplace.json   │
├────────────────────────────────────────────────────────────┤
│ 2  PACKAGING              plugins/*/.claude-plugin/plugin.json
│                           + README, LICENSE, CHANGELOG      │
├────────────────────────────────────────────────────────────┤
│ 3  CONTENT (the core)     plugins/*/skills/*/SKILL.md       │
│                           + references/ scripts/ assets/    │
└────────────────────────────────────────────────────────────┘
```

## The dependency rule

Dependencies point inward only. Inner layers know nothing about outer layers.

| Layer | Depends on | Must never know about |
|---|---|---|
| Content | nothing — pure [Agent Skills](https://agentskills.io) standard | plugins, marketplaces, Claude Code specifics |
| Packaging | Content (bundles skill dirs) | marketplace entries, other plugins |
| Distribution | Packaging (mirrors plugin manifests) | skill internals |
| Quality | Content (exercises skills) | packaging/distribution |
| Tooling | all layers (validates them) | — (outermost) |

Practical consequences:

- A SKILL.md must work if copied alone into any Agent Skills-compatible tool.
- Deleting `evals/` and `tools/` leaves a fully functional marketplace —
  those layers protect quality; they are not part of the runtime.
- `marketplace.json` is **derived state**: versions flow FROM plugin.json via
  `node tools/sync-versions.js`; hand-editing versions there is a CI failure.
- No skill may reference another plugin's files. Shared knowledge is
  duplicated or promoted into the style guide — cross-plugin coupling would
  break independent installability.

## Layer details

### Content — `plugins/<plugin>/skills/<skill>/`

Progressive disclosure in three levels (cost model: level 1 is always in
context, level 2 loads on trigger, level 3 loads on demand):

1. Frontmatter `name` + `description` (~100 tokens, always loaded) — the
   trigger surface. All routing intelligence lives in the description.
2. SKILL.md body (≤500 lines, target 60–200) — the workflow dispatcher.
3. `references/*.md` (deep matrices, one level deep), `scripts/`
   (executables run via bash, never loaded into context), `assets/`
   (templates to copy).

### Packaging — `plugins/<plugin>/`

The unit users install and the unit of versioning. Self-contained on
purpose: manifest, README, LICENSE, CHANGELOG travel with the plugin so it
can be extracted to its own repo without modification (see Evolution below).

### Distribution — `.claude-plugin/marketplace.json`

One marketplace (`ngocbinh-skills`) fronting all plugins with relative
`./plugins/<name>` sources. The entry schema also supports external
SHA-pinned sources (`git-subdir` + `sha`) — that is the designated mechanism
for third-party contributions, keeping external code out of this repo.

### Quality — `evals/`

Skills are developed test-first (RED baseline → GREEN with skill → REFACTOR
loopholes); see `evals/README.md`. Scenario files are the skill's spec;
SKILL.md is the implementation.

### Tooling — `tools/`, `.github/workflows/`, `docs/`

- `lint-frontmatter.js` — mechanical authoring rules.
- `sync-versions.js` — single-source-of-truth version propagation (+ `--check`).
- `validate.yml` — CI runs lint, sync-check, JSON validity, and
  `claude plugin validate` (the same check Anthropic's community pipeline runs).

## Key decisions (ADR summary)

| # | Decision | Rationale | Revisit when |
|---|---|---|---|
| 1 | Monorepo, not one-repo-per-plugin | Single author/team; atomic PRs across plugin+catalog; one CI/style guide; cheapest "add a plugin" path. Winners at this scale (wshobson, anthropics) do the same | An external maintainer needs ownership, or a plugin needs heavy divergent CI |
| 2 | Explicit semver in plugin.json, script-synced | SHA-versioning ships every commit to users; hand-syncing two files drifts (observed in wshobson). Script + CI check gives control without drift | — |
| 3 | Marketplace-first distribution, no custom npm installer | In-product discovery, auto-update, clean uninstall, Anthropic-endorsed; npm channel had documented security incidents and staleness. Generic `npx skills add` covers non-Claude users at zero cost | Anthropic ships an official npm mechanism |
| 4 | TDD via eval scenarios | The only proof a skill changes behavior; prevents shipping "nice docs" with no effect (methodology from superpowers + anthropics/skill-creator) | — |
| 5 | Skills contain no Claude-Code-only constructs | Portability across 30+ Agent Skills tools is free reach | A skill genuinely needs a hook/agent — then it stays optional |
| 6 | English content, bilingual root README | Global audience and trigger matching; Vietnamese quickstart for the home community | — |

## Change scenarios (what touches what)

| Change | Layers touched |
|---|---|
| Fix wording in a skill | Content + patch bump in Packaging (+ sync) |
| Add a skill to an existing plugin | Quality (scenarios first) → Content → minor bump |
| Add a new plugin | Packaging (new dir) + one Distribution entry |
| Accept an external plugin | Distribution only (SHA-pinned entry) |
| Change authoring rules | Tooling (docs + linter) — content sweep follows |

## Evolution path (planned-for, not built)

1. **Plugin extraction:** any `plugins/<name>/` is copy-out ready; the
   marketplace entry flips from relative source to a URL source. Users
   notice nothing.
2. **Catalog split:** if the ecosystem grows to many repos, a tiny
   catalog-only repo (superpowers-marketplace pattern) can front this one;
   install commands in circulation keep working via the `renames`/redirect
   entry mechanism.
3. **Release channels:** a `dev` marketplace entry pinned to `ref: dev` can
   be added alongside stable entries when pre-release testing needs users.
