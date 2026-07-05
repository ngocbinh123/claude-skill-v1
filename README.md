# bi-skills

**Bi**'s frontend skills for Claude — *bi* is short for Binh, the author.

Frontend engineering skills for **web and mobile**, with **React and React
Native at the core**, plus the workflows around them: Git, Android native,
iOS native, and UI design in Pencil. Built primarily for Claude Code; the
content follows the open [Agent Skills](https://agentskills.io) standard so
other agents can use it too.

Every plugin and skill carries the `bi-` prefix, so you always know which
guidance is loaded (`bi-rn-debugging`, `bi-commit-convention`, ...).

Every skill is developed test-first against pressure scenarios (see
[`evals/`](evals/README.md)) so it demonstrably changes agent behavior.

## Install (Claude Code)

```
/plugin marketplace add ngocbinh123/claude-skill-v1
/plugin install bi-git@bi-skills
/plugin install bi-react-native@bi-skills
/plugin install bi-android@bi-skills
/plugin install bi-ios@bi-skills
/plugin install bi-pencil@bi-skills
```

**Enable auto-updates** (off by default for third-party marketplaces):
open `/plugin` → **Marketplaces** tab → `bi-skills` → **Enable
auto-update**. Or update manually anytime with `/plugin marketplace update
bi-skills`.

## Install (Cursor, Codex, Copilot, other agents)

Skills follow the open Agent Skills standard, so you can install them with
any SKILL.md-compatible installer, e.g.:

```
npx skills add ngocbinh123/claude-skill-v1
```

## Plugins & skills

| Plugin | Skill | What it does |
|---|---|---|
| `bi-git` | `bi-commit-convention` | Conventional Commits: splitting changes, writing messages, breaking changes |
| | `bi-rebase-conflict` | Safe rebase, intent-based conflict resolution, reflog recovery |
| | `bi-pr-workflow` | Reviewable PRs: sizing, description structure, responding to review |
| `bi-react-native` | `bi-rn-debugging` | Layered triage of RN build/runtime failures (Metro, iOS, Android) with an error-signature matrix |
| | `bi-rn-performance` | Measure-first performance fixes: lists, re-renders, animations, startup, memory |
| `bi-android` | `bi-android-build-errors` | Gradle failure triage: toolchain, dependencies, resources, memory |
| `bi-ios` | `bi-ios-build-errors` | Xcode failure triage: signing, CocoaPods/SPM, compile, link, environment |
| `bi-pencil` | `bi-pencil-design` | Agent-driven UI design in [Pencil](https://pencil.dev) via its MCP tools: tokens-first, components-first, screenshot-verified |
| | `bi-pencil-mobile-screens` | Mobile screens in Pencil: device frames, safe areas, touch targets, handoff to RN/SwiftUI/Compose |

**Planned:** `bi-react` — React web skills (component architecture,
performance, debugging) to complete the web side of the library.

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

Thư viện skill của **Bi** (Bình) cho Claude Code — lập trình frontend web &
mobile, trọng tâm React và React Native, kèm Git, Android/iOS native và
design với Pencil. Mọi skill đều có tiền tố `bi-`.

Cài đặt trong Claude Code:

```
/plugin marketplace add ngocbinh123/claude-skill-v1
/plugin install bi-git@bi-skills
```

Sau khi cài, nhớ bật auto-update: `/plugin` → tab **Marketplaces** →
`bi-skills` → **Enable auto-update**.

Đóng góp skill mới: đọc `docs/authoring.md` — mọi skill đều viết theo TDD
(viết scenario kiểm thử trong `evals/` trước, viết SKILL.md sau).
