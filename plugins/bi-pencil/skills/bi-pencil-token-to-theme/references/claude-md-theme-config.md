# CLAUDE.md Config — extra keys for bi-pencil-token-to-theme

Append these keys to the existing `## Design Token Sync` section (created by
bi-pencil-token-to-code). Ask permission before writing. Project-specific
paths live ONLY here.

```markdown
- theme-spec: <path/to/design-theme-spec.md>
- theme-files: <path/to/theme-module.ts>, <path/to/legacy-theme-shim.ts>, <path/to/app-entry.tsx>
```

Worked example (React + MUI app):

```markdown
- theme-spec: docs/design-theme-spec.md
- theme-files: src/theme/get-app-theme.ts, src/theme/legacyTheme.ts, src/main.tsx
```

| Key | Required | Meaning |
|-----|----------|---------|
| `theme-spec` | yes | Committed spec doc driving phased implementation; carries per-item checkboxes; seeded from `theme-spec-template.md` on first run |
| `theme-files` | yes | The ONLY app files this skill may write. First entry = the theme module carrying the `// tokens-hash:` header |

Reused keys from the sync skill's section: `token-files` (locates
`design-tokens.json` + the token code dir), `verify-command`,
`showcase-dir` (visual check surface).

Validation: missing key → fail loud naming it; never guess paths.
