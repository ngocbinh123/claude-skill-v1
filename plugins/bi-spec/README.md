# bi-spec

Spec conformance skills for Claude Code.

| Skill | Triggers on | Teaches |
|---|---|---|
| `bi-spec-conformance` | "spec vs code", "compare spec implementation", "check implementation against spec", "find missing spec", "spec diff", "spec conformance", "spec not matching implementation" | Compare a branch's implementation against its spec; classify each requirement as correct / incorrect / missing / different with cited evidence; batch-confirm findings with the user; write a conformance report with suggested fixes (never edits code) |

## Install

```
/plugin marketplace add ngocbinh123/claude-skill-v1
/plugin install bi-spec@bi-skills
```

## Data handling

Plain-markdown skill: no external calls, no data collection, nothing executed
at install time. At run time it reads the repo (git diff, grep) and the
user-provided spec, and writes a report next to the spec.
