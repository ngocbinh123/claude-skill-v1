# Baseline & evidence — bi-pencil-token-to-theme

Runner: `node tools/run-evals.js --plugin bi-pencil --skill bi-pencil-token-to-theme`
(advice mode, model=sonnet, judge=haiku; JUnit XML in `evals/results/`).

## 2026-07-10 — RED evidence (pre-tightening)

First with-skill run failed 3/15 behaviors (S1 missing-header case, S2
structural-value comment rule, S5 CI-safe/no-MCP note) — all three were
scenario prompts that gave the agent no opening to exhibit the behavior;
prompts sharpened in scenarios.md (expectations unchanged).
Results: `evals/results/2026-07-10T07-45-13-592Z/`.

## 2026-07-10 — GREEN (advice-mode evidence)

S1-S5 all pass, 15/15 behaviors.
Results: `evals/results/2026-07-10T07-50-12-257Z/` (results.json, junit.xml).

This is advice-mode evidence: the judge grades the committed APPROACH, not
executed behavior — filesystem-dependent parts (hash computation, spec
checkbox resume) were not actually run. End-to-end execution evidence comes
from the flowcalc verification run (issue #8 AC, still open).
