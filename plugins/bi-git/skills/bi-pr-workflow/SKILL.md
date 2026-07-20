---
name: bi-pr-workflow
description: Prepare branches and open well-structured pull requests with a pre-PR validate gate (tests, lint, diff-size policy) and the Applify PR template, including self-review and responding to review feedback. Use when creating a pull request, preparing a branch for review, validating a diff before PR, writing a PR description, or addressing reviewer comments.
---

# Pull Request Workflow

## Overview

A PR is a communication artifact, not a code dump. Optimize for the reviewer:
small scope, clear narrative, zero surprises.

## Before opening the PR

1. Rebase onto the latest target branch so the diff contains only your change.
2. Self-review the FULL diff (`git diff <target>...HEAD`) as if reviewing a
   stranger's code. Remove: debug prints, commented-out code, unrelated
   formatting churn, accidental file additions.
3. Run the **validate gate** below — every step, in order. No PR while any
   step is red.
4. Clean the commit history: squash fixup noise (`wip`, `address review`)
   so each remaining commit stands alone.

## Validate gate (before opening any PR)

Ordered and non-skippable. A red step means STOP: report the failure and do
not push or open the PR. "It's flaky", "just style", or "I'll fix it later"
are not overrides — only an explicit user decision, with the risk restated,
may proceed past a warn (never past a hard stop).

1. **Detect the project's test command.** `package.json` → `npm test` (jest);
   `build.gradle`/`pom.xml` → junit via `gradle test`/`mvn test`. Detection
   fails → ASK the user for the command; never silently skip testing.
2. **Run tests.** Any failure ⇒ hard stop. Report the failing output. A claim
   that the failure is a known/flaky issue needs linked evidence (issue, CI
   history) before the user may decide to proceed.
3. **Run lint** (`npm run lint` or the detected linter). Failure ⇒ hard stop,
   same as tests. Offer to fix the errors first.
4. **Measure the diff** against the target branch — BOTH metrics, excluding
   lockfiles (`package-lock.json`, `yarn.lock`, `poetry.lock`, …) and
   auto-generated code from the line count:
   - Files (`git diff --name-only <target>...HEAD`): ≤10 pass; 11–15 warn —
     cite the ≤10 target (POL-ENG-003) and proceed only with explicit user
     consent; >15 hard stop.
   - Net lines (`git diff --numstat <target>...HEAD` summed): ≤400 pass;
     401–800 warn; >800 hard stop.
   - Any hard stop ⇒ propose a multi-PR split. Default delivery order:
     **markdown files first, then UI components, then remaining files**.
     Reorder only when a dependency between groups forces it, and say why.
     The user confirms the split before anything is pushed.
5. **Policy checks** (POL-ENG-001): not committing on `main`/`master`; the
   branch carries the ticket id; the diff is ONE logical concern — one
   releasable increment per PR.

## PR title and description

Title follows the same convention as commits: `type(scope): subject`. When
the user offers a vague title ("fix stuff", "updates"), don't just cite the
convention — PROPOSE a concrete conventional title derived from the diff
(e.g. `fix(auth): handle expired refresh tokens`), even if it's a best-guess
the user can correct.

**The Applify template ALWAYS wins.** Write every PR description with the
embedded Applify template and fill rules in
[references/applify-pr-rules.md](references/applify-pr-rules.md) — even when
the repo has its own `.github/PULL_REQUEST_TEMPLATE*`. State that the Applify
template was used. Only if the reference file is missing fall back to a
minimal What / Why / How / Testing / Risk structure.

> Scope note: this Applify-first rule is intentional and specific to this
> skill. The generic `bi-git-workflow` (`cp`/`pr`) skill instead follows the
> host repo's template — the two are scoped to different contexts on purpose.

## Applify PR creation

After the validate gate is fully green, build the PR from
`references/applify-pr-rules.md`. Keep the body short and ticket-focused.
Summary of the non-negotiables (full rules and the embedded template live in
the reference):

- **Summary** is 1–3 sentences on the behavior shipped — not a walkthrough of
  every change.
- **Scope** names only the key classes/files or scenarios affected; do not
  enumerate every changed line.
- **Acceptance criteria** are copied verbatim from the ticket — do not reword
  or re-derive them.
- **Test plan** targets happy cases + common edge cases. ASK the user for the
  list of test-plan items and the verified/not-verified status of each —
  never invent or pre-tick them.
- **"Unit/integration tests pass"** is ticked ONLY because the gate actually
  ran the tests; record the exact command in the checkbox line.
- **Migration / deployment notes**: React / React Native projects → write
  "None" directly (do NOT ask — there is nothing to deploy server-side).
  Backend projects only → ask the user about DB migrations, flags, schemas.
- **Redmine** is left empty. There is **no Reviewers section and no Reviewer
  notes section** — do not add them and do not auto-request reviewers.

Rules:

- The description must be understandable WITHOUT reading the diff.
- Screenshots/recordings are mandatory for visual changes (before/after).
- Call out the parts you are unsure about — directing reviewer attention is a
  strength, not a weakness.

## Responding to review

1. Address every comment — with a code change or a reasoned reply, never
   silence.
2. Push review fixes as NEW commits (don't force-push mid-review) so the
   reviewer can see what changed; squash after approval if the repo prefers.
3. If a suggestion is wrong or out of scope, say why briefly and offer a
   follow-up issue when it has merit.
4. When discussion loops more than twice on one thread, propose a quick call
   or defer to the repo's convention/owner — comment threads are a bad place
   for design debates.

## Anti-patterns

- Do NOT open a PR whose description is empty or just repeats the title.
  When the user says "no description needed", write (or offer) the
  What/Why/Testing sections anyway and explain the concrete harm of an empty
  one: the reviewer must reverse-engineer intent from the diff, review slows
  down and misses context, and future maintainers doing archaeology on the
  merged PR find nothing.
- Do NOT mix "drive-by" fixes into a feature PR — separate PR, easy approve.
- Do NOT open a PR while tests or lint are red — not even "just this once"
  or "it's a known flaky test" without linked evidence and an explicit user
  decision.
- Do NOT tick the "Unit/integration tests pass" checkbox without a real test
  run in this session, and do NOT fill test-plan verified statuses the user
  never confirmed.
- Do NOT pad the Summary or Scope into a design doc — Summary is 1–3
  sentences, Scope names the key files/scenarios only.
- Do NOT reword or re-derive the ticket's acceptance criteria — copy them
  verbatim.
- Do NOT add a Reviewers or Reviewer notes section, and do not auto-request
  reviewers.
- Do NOT mark threads resolved on the reviewer's behalf without a change or
  an agreed reply.
- Do NOT merge on red or flaky CI ("it's unrelated") without linking evidence
  that the failure is a known issue.
