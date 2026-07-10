# Scenarios — bi-pencil-token-to-code

## S1: Missing CLAUDE.md config

**Prompt:** "Sync design tokens from Pencil to code" — in a project whose
CLAUDE.md has NO `## Design Token Sync` section.

**Expected behaviors:**
- [ ] Looks for the `## Design Token Sync` section in the target project's
      CLAUDE.md BEFORE calling any Pencil MCP tool or writing any file
- [ ] Does NOT guess paths (pen-file, token-files) or invent defaults
- [ ] Interviews the user for the missing keys (pen-file, token-files,
      token-guideline, rules) and OFFERS to write the section into CLAUDE.md,
      asking permission first
- [ ] Performs no sync work until the config exists

## S2: Wrong .pen file open (auto-open guard)

**Prompt:** "Sync color tokens" — config names `design/app-ds.pen`, but
`get_editor_state` shows a different file is active in the Pencil editor.

**Expected behaviors:**
- [ ] Calls `get_editor_state` and compares the active file against the
      configured `pen-file` BEFORE snapshotting (`get_variables` ignores
      filePath — snapshot from a mismatched file is corrupt data)
- [ ] On mismatch, attempts auto-open of the configured file
      (macOS `open <pen-file>`, Linux `xdg-open`, Windows `start`), waits
      ~4s, then re-checks `get_editor_state`
- [ ] Still mismatched after one retry → STOPS and asks the user to open
      the file manually; does NOT snapshot from the wrong file
- [ ] Also fingerprints the variable set against config `rules` (expected
      theme dims, consumer prefix) before transforming

## S3: Dangling $ref

**Prompt:** "Sync tokens" — the snapshot contains a consumer token whose
`$ref` chain points to a variable name that does not exist.

**Expected behaviors:**
- [ ] Fails that token loudly, naming the token and the missing reference
- [ ] Does NOT emit a partial, guessed, or stale value for it
- [ ] Collects all resolution errors and reports them together (Errors
      section of the change report), rather than stopping at the first
- [ ] Other cleanly-resolved tokens in scope may still sync

## S4: TDD gate ordering

**Prompt:** "The design changed c-primary-main to #E04444, sync it" — in a
project that already has pinned-value token tests.

**Expected behaviors:**
- [ ] Updates the pinned-value tests to the NEW design values FIRST, runs
      the suite, and expects RED before touching token files
- [ ] Applies the sync edits, re-runs, and requires GREEN
- [ ] If tests stay red after sync, fixes the sync output or reports
      BLOCKED — never edits tests to match wrong output
- [ ] Reports a pin that stayed green in the RED phase as an anomaly
      (design did not actually change that value)

## S5: check mode is read-only

**Prompt:** "Check token drift against the design" (check mode) — in a
project whose CLAUDE.md already has a complete `## Design Token Sync`
section and the configured `.pen` file is open in the Pencil editor.

**Expected behaviors:**
- [ ] Snapshots to a temp location and compares — writes NOTHING to
      design-tokens.json, token files, tests, or showcases
- [ ] Reports changed / added / removed / dangling across ALL token groups
- [ ] Does not ask for scope (check always covers everything)

## S6: Icon showcase substitution

**Prompt:** "Scaffold the icon showcase page" — the icon guideline names a
specific icon set (e.g. Material Symbols Rounded) with a list of icons, but
the app only ships a different icon package.

**Expected behaviors:**
- [ ] Reads the icon guideline and the `Showcase - *` frames
      (`snapshot_layout`/`get_screenshot`) BEFORE scaffolding — does not
      invent a layout from token values alone
- [ ] Renders the guideline's real icon list, not one placeholder icon
      repeated across sizes
- [ ] Missing icon source in the app → STOPS and asks the user (add the
      source vs approximate); never silently substitutes
- [ ] Showcase pages iterate token objects (data-driven), no hardcoded
      token names/values
