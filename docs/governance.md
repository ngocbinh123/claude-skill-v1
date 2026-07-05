# Governance & Rules

## Hard rules (CI-enforced or review-blocking)

1. **TDD is not optional.** A new or changed skill lands only with
   `evals/<plugin>/<skill>/scenarios.md` written first and GREEN evidence
   recorded. A skill whose baseline already passes is rejected — it doesn't
   earn its context cost.
2. **Frontmatter: exactly `name` + `description`.** Kebab-case name matching
   the directory; description in third person containing a "Use when ..."
   trigger phrase. (`tools/lint-frontmatter.js`)
3. **SKILL.md body ≤ 500 lines.** Depth belongs in `references/` (one level
   deep), executables in `scripts/`, templates in `assets/`.
4. **Versions are edited in plugin.json only**, propagated by
   `tools/sync-versions.js`. CI fails on drift.
5. **`main` is always releasable.** CI-green, evals GREEN, no WIP — the
   community marketplace sweep can publish `main` HEAD within a day.
6. **No cross-plugin references.** Each plugin must remain independently
   installable and extractable.
7. **Skills stay portable.** No Claude-Code-only constructs inside SKILL.md
   content; anything harness-specific is a deliberate, documented exception.

## Quality gates — the two-step PR gate

Every PR passes two automated steps before human review:

**Step 1 — style & rules** (`.github/workflows/validate.yml`, free, always on):

| Check | Tool |
|---|---|
| Frontmatter lint | `node tools/lint-frontmatter.js` |
| Governance rules (evals exist, plugin completeness, bi- prefix) | `node tools/check-governance.js` |
| Version sync | `node tools/sync-versions.js --check` |
| Manifest validity | `claude plugin validate` per plugin (same check as Anthropic's pipeline) |

**Step 2 — behavioral evals, "JUnit for skills"**
(`.github/workflows/skill-evals.yml`, runs on PRs touching `plugins/**` or
`evals/**`; requires the `ANTHROPIC_API_KEY` repo secret):

`tools/run-evals.js` runs each touched plugin's scenarios through a headless
Claude with the skill injected, grades every expected behavior with an LLM
judge, and fails the PR if any behavior fails. Results publish as JUnit XML
artifacts. See `evals/README.md` for local usage and known limits.

**Step 3 — human review**: does the eval evidence hold, is the skill
opinionated, is the description trigger-complete.

## Contribution workflow

1. Open an issue describing the skill idea and the failure mode it fixes.
2. Branch; write `scenarios.md`; record the RED baseline.
3. Write the skill per `docs/authoring.md`; iterate to GREEN.
4. Bump version, sync, changelog; open a PR using the checklists in
   `authoring.md`.
5. Review focuses on: does the eval evidence hold, is the skill opinionated,
   is the description trigger-complete.

External (non-maintainer) plugins are not merged into this repo — they join
the marketplace as SHA-pinned external entries in `marketplace.json`,
mirroring how `claude-plugins-official` handles third-party code.

## Security & data-handling policy

- Plugins in this repo are plain-markdown skills: **no network calls, no
  data collection, no install-time execution**. This statement is kept in
  every plugin README (community-marketplace reviewers check data handling).
- `scripts/` inside skills must be self-contained, read-only by default,
  must not download-and-execute remote code, and must not touch anything
  outside the working directory without the workflow explicitly saying so.
- Dependencies: none. The tooling layer is dependency-free Node stdlib on
  purpose — nothing to supply-chain-attack.
- Anything violating this section is a review-blocker regardless of value.

## Decision log

Significant decisions are recorded in `docs/architecture.md` (ADR summary
table) with rationale and revisit-conditions. Amend the table when a
decision changes; do not silently diverge.
