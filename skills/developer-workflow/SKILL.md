---
name: developer-workflow
description: This skill should be used when the user asks to investigate a bug, implement a feature, refactor existing code, add or update tests, debug CI or build failures, or needs a disciplined software development workflow in Claude Code.
version: 1.0.0
license: MIT
---

# Developer Workflow

Use this skill to complete software development tasks with a safe, efficient, minimal-change workflow.

## Primary goals

- understand the request and constraints before editing code
- inspect the repository and existing commands before making changes
- prefer the smallest complete implementation that solves the problem
- validate behavior with focused tests and manual checks when possible
- leave a concise summary of what changed, what was verified, and any remaining risk

## When this skill applies

Activate this skill when the task involves:

- fixing bugs or regressions
- implementing a scoped feature
- updating code and tests together
- investigating build, lint, or CI failures
- reviewing a repository before making a change

## Recommended workflow

1. **Understand the task**
   - Restate the goal, constraints, and success criteria.
   - Identify whether the request is code, test, documentation, or workflow related.

2. **Explore before editing**
   - Inspect the repository structure and relevant files.
   - Find existing lint, build, and test commands.
   - Review nearby code patterns before introducing new structure.

3. **Plan a minimal change**
   - Prefer updating existing files over creating new abstractions.
   - Limit scope to files directly needed for the request.
   - Note any edge cases that must still be covered.

4. **Implement incrementally**
   - Make small edits that can be reviewed easily.
   - Keep behavior aligned with existing conventions.
   - Update related documentation when the change affects usage or setup.

5. **Verify**
   - Run targeted tests first, then broader verification if needed.
   - If there is no test infrastructure, perform manual validation and say so clearly.
   - Confirm the change does not introduce secrets or obvious security issues.

6. **Report results**
   - Summarize the change in plain language.
   - List validation steps performed.
   - Call out follow-up work only when it is genuinely required.

## Quality guardrails

- avoid unrelated refactors
- do not remove tests to make failures disappear
- prefer existing tools and repository conventions
- keep documentation consistent with the implemented behavior
- be explicit when assumptions or missing infrastructure limit verification

## Example requests

- "Fix the failing login test without changing unrelated auth behavior."
- "Add a small feature to export the current report as CSV."
- "Investigate why CI is failing on the build step."
- "Update the README and implementation so the setup instructions match."
