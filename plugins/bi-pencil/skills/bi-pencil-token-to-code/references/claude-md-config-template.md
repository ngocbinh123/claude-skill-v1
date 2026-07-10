# CLAUDE.md Config Template — `## Design Token Sync`

Copy this section into the target project's `CLAUDE.md` (ask permission
before writing). All paths repo-relative unless absolute is unavoidable.
Project-specific info lives ONLY here — the skill carries none.

```markdown
## Design Token Sync

Config for the bi-pencil-token-to-code skill (design → code token sync).

- pen-file: <path/to/design-system.pen>
- token-files: <path/to/tokens/design-tokens.json>, <path/to/tokens/*.ts>
- token-guideline: <path/to/design-token-guideline-docs/>
- rules: theme dims = <dim>[<values>] x <dim>[<values>]; UI reads ONLY <consumer-prefix>-* tier; <other-tier-prefixes> never exported to code; supplemental composites (shadows, letter-spacing, weight/line-height) sourced from token-guideline docs
- verify-command: <test/build command>
- showcase-dir: <path/to/showcase-pages/>
```

Worked example (a two-brand, light/dark React app):

```markdown
- pen-file: design/app-design-system.lib.pen
- token-files: src/theme/tokens/design-tokens.json, src/theme/tokens/*.ts
- token-guideline: docs/design/design-token/
- rules: theme dims = brand[alpha,beta] x mode[light,dark]; UI reads ONLY c-* tier; p-*/a-*/b-* never exported to code; supplemental composites from token-guideline docs
- verify-command: npm test
- showcase-dir: src/pages/design-dashboard/
```

## Key semantics

| Key | Required | Meaning |
|-----|----------|---------|
| `pen-file` | yes | The design-system `.pen` that MUST be open in the Pencil editor when snapshotting (get_variables ignores filePath). The skill auto-opens it when a different file is active |
| `token-files` | yes | The ONLY code paths the skill may write (besides token test files). First entry should be the committed `design-tokens.json` audit artifact |
| `token-guideline` | yes | Dir of design-token guideline docs (source for composites not expressible as Pencil variables, and the icon set/list) |
| `rules` | yes | Fingerprint + transform contract: expected theme dimensions, consumer-tier prefix, forbidden tiers, project-specific conventions |
| `verify-command` | no | Command run after sync (tests/build). Doubles as the TDD suite runner |
| `showcase-dir` | no | Dir of data-driven token showcase pages + dashboard. Asked for on first Step 5 run if missing |

## Validation rules (skill-side)

- Missing section → interview user → offer to write it (ask permission).
- Missing required key → fail loud naming the key; do not guess defaults.
- `pen-file` not matching the active Pencil editor file → auto-open once,
  re-check; still mismatched → hard stop, ask the user.
- If the project has no token test suite yet, omit `verify-command`; the
  skill scaffolds suites on first sync and proposes the command to add here.
