# Roadmap

Status legend: ✅ done · 🔄 in progress · ⬜ planned

## Phase 0 — Foundation ✅

- ✅ Distribution research (npm vs marketplace) and channel decision
- ✅ Architecture dissection of leading repos; five-layer design
- ✅ Repo scaffold: marketplace, 4 plugins, tooling, CI, style guide
- ✅ Foundational docs (goals, architecture, versioning, governance)

## Phase 1 — Prove the loop (bi-git) 🔄

- ✅ 3 skills drafted: bi-commit-convention, bi-rebase-conflict, bi-pr-workflow
- ✅ Automated eval harness: `tools/run-evals.js` (headless arms + LLM judge
  + JUnit output) with CI gate `skill-evals.yml`; first RED/GREEN evidence
  recorded (bi-rn-debugging S1: baseline 0/3 → with-skill 3/3)
- ✅ First full with-skill run (2026-07-05): 24/28 green, 4 gaps fixed in
  the 0.1.1 patches, re-run confirms 28/28 green
- ⬜ Run RED baselines for all bi-git scenarios (`node tools/run-evals.js
  --plugin bi-git --ablation`) and record in `evals/*/baseline.md`
- ⬜ Iterate skills to GREEN; record evidence
- ⬜ Local install test (`/plugin marketplace add <local path>`)
- ⬜ Merge to `main` → first public release `bi-git-v0.1.0`

## Phase 2 — Mobile depth 🔄

- ✅ bi-rn-debugging (+ build-error matrix), bi-rn-performance drafted
- ✅ bi-android-build-errors, bi-ios-build-errors starters drafted
- ⬜ Evals RED/GREEN for all mobile skills
- ⬜ New skills: `rn-release` (signing, store submission, OTA),
  `rn-native-modules` (Turbo Modules / New Architecture),
  `android-compose-performance`, `ios-signing`
- ✅ `bi-pencil` scope defined: Pencil (pencil.dev) agent-driven design
  via its MCP tools, mobile-first. Two skills drafted (`bi-pencil-design`,
  `bi-pencil-mobile-screens`) with scenarios
- ⬜ Evals RED/GREEN for bi-pencil (requires an environment with the
  Pencil app + MCP connected)

## Phase 2.5 — React web (`bi-react`) ⬜

- ⬜ Scope the first React web skills (candidates: `bi-react-performance`,
  `bi-react-architecture`, `bi-react-debugging`)
- ⬜ Scenarios first (TDD), then skills, per the standard loop

## Phase 3 — Public launch ⬜

- ⬜ Polish bilingual README; add screenshots/GIF of a skill firing
- ⬜ Announce to RN/mobile communities (VN + international); gather issues
- ⬜ List on skills.sh for cross-tool installs + analytics
- ⬜ Enable-auto-update instructions verified with real users

## Phase 4 — Community marketplace ⬜

- ⬜ Pre-submission audit: `claude plugin validate` clean, per-plugin
  LICENSE/README/data-handling statement, stable `main`
- ⬜ Submit via platform.claude.com/plugins/submit
- ⬜ After acceptance: verify daily SHA-bump propagation; document the
  observed latency

## Phase 5 — Sustain ⬜

- ⬜ Issue-driven skill additions; monthly release cadence
- ⬜ Consider release channels (`dev` ref entry) when pre-release testers exist
- ⬜ Revisit ADR #1 (monorepo) only if an external maintainer or heavy CI
  divergence appears
