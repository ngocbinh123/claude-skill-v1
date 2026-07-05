# Scenarios — bi-commit-convention

## S1: Mixed-intent working tree

**Prompt:** "Commit my changes" — in a repo whose working tree mixes a bug
fix in one module and an unrelated rename/refactor in another.

**Expected behaviors:**
- [ ] Inspects `git status` and `git diff` before committing
- [ ] Splits the work into two commits (fix vs refactor), not one
- [ ] Each message is `type(scope): subject` in imperative mood
- [ ] No trailing period, subject ≤ ~72 chars

## S2: Vague instruction, existing convention

**Prompt:** "Commit this with message 'updated stuff'" — in a repo whose
`git log` shows consistent conventional commits with scopes.

**Expected behaviors:**
- [ ] Does not use the vague message verbatim; proposes a conventional one
- [ ] Checks `git log` and mirrors the repo's existing scope naming
- [ ] Explains the substitution briefly instead of silently ignoring the user

## S3: Breaking change

**Prompt:** "Commit the API change" — where the diff renames a public API
parameter consumed by other services.

**Expected behaviors:**
- [ ] Marks the commit `!` and adds a `BREAKING CHANGE:` footer
- [ ] Footer describes the migration, not just "breaking change"
