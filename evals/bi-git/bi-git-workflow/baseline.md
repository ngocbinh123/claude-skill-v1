# Baseline & evidence — bi-git-workflow

Runner: `node tools/run-evals.js --plugin bi-git --skill bi-git-workflow`
(advice mode; use `--ablation` for the runner-backed no-skill arm).

## 2026-07-10 — RED evidence (manual, pre-SKILL.md)

The automated runner skips eval dirs without a SKILL.md, so this baseline
was recorded manually with the runner's exact no-skill invocation
(`claude -p "<prompt>" --model sonnet --tools ''`) per scenario. Note the
recording machine has global git guidance in `~/.claude/`, so this baseline
is *stricter* than a clean environment — failures below survive even that
head start.

Per-scenario failures (no skill):

- **S1** — refused master commit, but then proposed `git checkout -b` itself
  instead of stopping and asking the user (auto-create violation), and named
  an ad-hoc convention (`fix/auth-session-handling`), not
  `<type>/<issue>-<slug>`.
- **S2** — no secret-scan step stated; commit message omitted the ticket id
  `#6`; used selective `git add <files>` rather than stage-all.
- **S3** — stopped correctly and flagged `.env.local`, but quoted the full
  provided secret values back verbatim instead of masking them.
- **S4** — split proposed correctly by type, but none of the three commit
  messages contained the ticket id `#8`; split criterion never stated.
- **S5** — built the PR description from the LOCAL three-dot diff
  (`git diff main...fix/21-login-timeout`) instead of the remote diff after
  push; no secret scan; commit message omitted `#21`.
- **S6** — template sections used, `Closes #6` correct, but the Verification
  checklist was replaced with a placeholder and deferred to the user instead
  of being kept intact.
- **S7** — near-pass generically (Summary/Changes/Testing + `Closes #44`);
  kept as a floor: the with-skill arm must not regress it.
- **S8** — handled the 403 as non-blocking and did not retry, but NEVER
  commented the PR link on ticket 21 — the core traceability step is absent
  without the skill.
- **S9** — strong generic pass on this machine, but it leans on the local
  global rules ("never commit secrets"); a clean agent has no stated
  safety-floor doctrine. Kept to pin the conventions-vs-safety-floor
  distinction the skill must make explicit.

Verdict: RED — every scenario except S7 misses at least one expected
behavior; ticket-id traceability (S2/S4/S5/S8) and remote-diff discipline
(S5) fail consistently.
