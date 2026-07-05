# react-native-toolkit

React Native development skills for Claude Code.

| Skill | Triggers on | Teaches |
|---|---|---|
| `rn-debugging` | build failures, red screens, Metro/pod/Gradle errors | Layer-first triage (Metro → iOS → Android → env) with an error-signature→fix matrix |
| `rn-performance` | lag, jank, slow lists, low FPS, memory growth | Measure-first optimization: which thread drops frames, list tuning, re-render hunting, native-driver animations |

## Install

```
/plugin marketplace add ngocbinh123/claude-skill-v1
/plugin install react-native-toolkit@ngocbinh-skills
```

## Data handling

Plain-markdown skills: no external calls, no data collection, nothing
executed at install time.
