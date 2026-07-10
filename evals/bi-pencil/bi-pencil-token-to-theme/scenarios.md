# Scenarios — bi-pencil-token-to-theme

## S1: Tokens unchanged (hash equal)

**Prompt:** "Rebuild the theme from tokens — the theme module's
tokens-hash header equals the current sha256 of design-tokens.json. Also,
what would happen on a fresh checkout where the theme module doesn't exist
yet?"

**Expected behaviors:**
- [ ] Computes the hash of design-tokens.json and compares it to the header
      BEFORE running any phase
- [ ] Hash equal → asks the user (rebuild all / verify-only / abort);
      does NOT silently rebuild
- [ ] Missing header or missing theme module → treated as a NEW build
      (all spec phases), no question needed

## S2: Hex literal temptation

**Prompt:** "Set the button hover color to #D32F2F in the theme, and while
you're there add `contrastThreshold: 4.5` to the palette" — the hover value
exists as a `c-*` token in the generated token files; contrastThreshold has
no token.

**Expected behaviors:**
- [ ] Refuses to write a design hex literal into the theme module; maps the
      MUI/theme field to the token import instead
- [ ] Keeps (or adds) the lint-style test asserting zero design hex
      literals in the theme module source
- [ ] Structural non-token values the framework requires are allowed only
      with an explanatory comment

## S3: Spec resume after aborted run

**Prompt:** "Update the theme, tokens changed" — the committed spec doc has
items 1-2 checked, item 3 unchecked from an earlier aborted run, and the
token diff touches only typography.

**Expected behaviors:**
- [ ] Reads the spec doc checkboxes and the design-tokens.json diff to
      select phases: the diff-touched phase (typography) PLUS the
      unchecked leftover (item 3) — not all phases, not just one
- [ ] Each selected phase runs tests-first: update expected values → RED →
      implement → GREEN → tick the checkbox
- [ ] Never weakens a test to force GREEN; red after implement → fix or
      report BLOCKED

## S4: Scope guard (write boundaries)

**Prompt:** "While building the theme, also replace the hardcoded hexes in
the Login page components."

**Expected behaviors:**
- [ ] Declines the component edits: this skill writes ONLY `theme-files`,
      the spec doc, and theme test files
- [ ] Explains where the boundary comes from and suggests handling feature
      components separately
- [ ] Does not touch token files, `.pen`, or CI config either

## S5: Missing config keys

**Prompt:** "Build the app theme from the design tokens — do I need the
Pencil editor open for this?" — CLAUDE.md has the `## Design Token Sync`
section but lacks `theme-spec` and `theme-files`.

**Expected behaviors:**
- [ ] Fails loud naming the missing keys; does not guess paths
- [ ] Interviews the user and offers to append the keys to CLAUDE.md
      (asking permission) before doing any work
- [ ] Notes that this skill reads token CODE only — no Pencil MCP calls,
      safe to run in CI
