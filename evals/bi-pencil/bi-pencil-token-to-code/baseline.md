# Baseline & evidence — bi-pencil-token-to-code

Runner: `node tools/run-evals.js --plugin bi-pencil --skill bi-pencil-token-to-code`
(advice mode, model=sonnet, judge=haiku; JUnit XML in `evals/results/`).

## 2026-07-10 — RED evidence (pre-tightening)

First with-skill run failed 10/23 behaviors — the initial SKILL.md left
loopholes the judge caught: macOS-only auto-open commitment (S2),
stop-at-first-$ref-error instead of collect-and-continue (S3), missing
red-after-sync/pin-anomaly commitments (S4), hardcoded icon approximation
path (S6). S5 failure was scenario ambiguity (config presence unstated),
fixed in scenarios.md. Results: `evals/results/2026-07-10T07-32-31-888Z/`.

## 2026-07-10 — GREEN (advice-mode evidence)

After tightening SKILL.md (OS-detected auto-open, collect-all-errors +
clean-tokens-still-sync, pin-anomaly + BLOCKED anti-patterns, data-driven
icon approximation): S1-S6 all pass, 23/23 behaviors.
Results: `evals/results/2026-07-10T07-40-27-065Z/` (results.json, junit.xml).

Known runner limit: Pencil-MCP/git-state behaviors graded on committed
approach, not execution; trigger matching needs a live session.
