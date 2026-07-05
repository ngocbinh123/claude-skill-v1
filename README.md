# ngocbinh-skills

Frontend & mobile engineering skills for Claude Code (and any agent that
reads the [Agent Skills](https://agentskills.io) standard): **Git, React
Native, Android native, iOS native** — with more toolkits on the way.

Every skill is developed test-first against pressure scenarios (see
[`evals/`](evals/README.md)) so it demonstrably changes agent behavior.

## Install (Claude Code)

```
/plugin marketplace add ngocbinh123/claude-skill-v1
/plugin install git-toolkit@ngocbinh-skills
/plugin install react-native-toolkit@ngocbinh-skills
/plugin install android-toolkit@ngocbinh-skills
/plugin install ios-toolkit@ngocbinh-skills
```

**Enable auto-updates** (off by default for third-party marketplaces):
open `/plugin` → **Marketplaces** tab → `ngocbinh-skills` → **Enable
auto-update**. Or update manually anytime with `/plugin marketplace update
ngocbinh-skills`.

## Install (Cursor, Codex, Copilot, other agents)

Skills follow the open Agent Skills standard, so you can install them with
any SKILL.md-compatible installer, e.g.:

```
npx skills add ngocbinh123/claude-skill-v1
```

## Plugins & skills

| Plugin | Skill | What it does |
|---|---|---|
| `git-toolkit` | `commit-convention` | Conventional Commits: splitting changes, writing messages, breaking changes |
| | `rebase-conflict` | Safe rebase, intent-based conflict resolution, reflog recovery |
| | `pr-workflow` | Reviewable PRs: sizing, description structure, responding to review |
| `react-native-toolkit` | `rn-debugging` | Layered triage of RN build/runtime failures (Metro, iOS, Android) with an error-signature matrix |
| | `rn-performance` | Measure-first performance fixes: lists, re-renders, animations, startup, memory |
| `android-toolkit` | `android-build-errors` | Gradle failure triage: toolchain, dependencies, resources, memory |
| `ios-toolkit` | `ios-build-errors` | Xcode failure triage: signing, CocoaPods/SPM, compile, link, environment |

## Data handling

These plugins are plain-markdown skills. They call no external services,
collect no data, and execute nothing at install time.

## Project documentation

Start at the [docs index](docs/README.md): [goals](docs/goals.md) ·
[architecture & decision log](docs/architecture.md) ·
[versioning & releases](docs/versioning.md) ·
[governance & rules](docs/governance.md) · [roadmap](docs/roadmap.md).

## Contributing

Read [`docs/authoring.md`](docs/authoring.md) (style guide + checklists) and
[`evals/README.md`](evals/README.md) (the TDD loop). Quick validation:

```bash
node tools/lint-frontmatter.js && node tools/sync-versions.js --check
```

## License

[MIT](LICENSE)

---

## Tiếng Việt

Thư viện skill cho Claude Code hỗ trợ lập trình frontend/mobile: Git, React
Native, Android native, iOS native.

Cài đặt trong Claude Code:

```
/plugin marketplace add ngocbinh123/claude-skill-v1
/plugin install git-toolkit@ngocbinh-skills
```

Sau khi cài, nhớ bật auto-update: `/plugin` → tab **Marketplaces** →
`ngocbinh-skills` → **Enable auto-update**.

Đóng góp skill mới: đọc `docs/authoring.md` — mọi skill đều viết theo TDD
(viết scenario kiểm thử trong `evals/` trước, viết SKILL.md sau).
