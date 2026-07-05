# Skill Evals — TDD for skills

Every skill in this repo is developed test-first. A skill's "test suite" is a
set of pressure scenarios: realistic prompts where an agent WITHOUT the skill
behaves wrongly, and an agent WITH the skill must behave correctly.

## The loop (RED → GREEN → REFACTOR)

1. **RED — capture the baseline.** Before writing the skill, run each
   scenario prompt in a fresh Claude Code session WITHOUT the plugin
   installed. Record the failure modes in `baseline.md` (what the agent did
   wrong or generically). If the agent already behaves correctly without the
   skill, the scenario is too easy — sharpen it or drop the skill idea.
2. **GREEN — write the skill until scenarios pass.** Install the plugin from
   the local checkout and re-run each scenario in a fresh session:

   ```
   /plugin marketplace add /path/to/claude-skill-v1
   /plugin install <plugin>@bi-skills
   ```

   A scenario passes when the observable behavior matches every item in its
   `Expected behaviors` list AND the skill actually triggered (the session
   shows the skill being loaded).
3. **REFACTOR — close loopholes.** When a scenario passes for the wrong
   reason, or the agent rationalizes around a rule, tighten the SKILL.md
   (usually the anti-patterns section) and re-run.

## Layout

```
evals/<plugin>/<skill>/
├── scenarios.md   # numbered scenarios: prompt + expected behaviors
└── baseline.md    # recorded pre-skill behavior (RED evidence), dated
```

## Grading

Grade manually against the checklist, or ask a second Claude session to act
as judge: paste the transcript and the expected-behaviors list, and ask for a
pass/fail per item with evidence quotes. Re-run scenarios whenever the
corresponding SKILL.md changes.

## Automated runner ("JUnit for skills")

`tools/run-evals.js` automates the loop in advice mode (headless `claude -p`
with all tools disabled; the with-skill arm injects SKILL.md as a triggered
skill; an LLM judge grades each expected behavior; results land in
`evals/results/` as JSON + JUnit XML):

```bash
node tools/run-evals.js --dry-run                    # list parsed cases (no API calls)
node tools/run-evals.js --plugin bi-git              # gate one plugin
node tools/run-evals.js --plugin bi-react-native --skill bi-rn-debugging \
  --scenario S1 --ablation                           # RED+GREEN for one scenario
```

CI runs this on every PR touching `plugins/**` or `evals/**`
(`.github/workflows/skill-evals.yml`, needs the `ANTHROPIC_API_KEY` secret).

Limits to know: the runner tests behavior compliance, not trigger matching
(the skill is force-injected) — trigger testing still needs a real session
where you speak naturally and watch whether the skill loads. Scenarios that
depend on live tools (bi-pencil's MCP calls, real git state) are graded on
the committed approach, not execution. Claude Code also ships a native
`claude plugin eval` (early access) with the same with/without-ablation
idea — we migrate to it when it stabilizes.
