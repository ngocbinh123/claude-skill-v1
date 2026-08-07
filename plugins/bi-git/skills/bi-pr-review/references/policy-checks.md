# Policy checks (advisory)

Mirror the policy `bi-pr-workflow` enforces, but report it as advisory flags —
this skill reviews, it does not gate. Never refuse to produce the review because
a policy is violated; surface the violation in the report's **Policy checks**
section and let the author decide.

`<base>` is the PR base branch (`gh pr view --json baseRefName`) or the
locally-resolved default branch (`git symbolic-ref refs/remotes/origin/HEAD`).

## 1. Commit count — exactly 1

```bash
git rev-list --count <base>..HEAD      # local
gh pr view <n> --json commits --jq '.commits | length'   # PR mode
```

- `== 1` → ✅. Otherwise ⚠️ flag: squash to one releasable increment (POL-ENG-001,
  one logical concern per PR). This is #25's `> 0 && < 2` rule.

## 2. Changed files (POL-ENG-003)

```bash
git diff --name-only <base>...HEAD \
  | grep -vE '(package-lock\.json|yarn\.lock|pnpm-lock\.yaml|poetry\.lock|Gemfile\.lock|go\.sum)$' \
  | grep -vE '\.(generated|g)\.(ts|js|dart)$' \
  | wc -l
```

- ≤10 → ✅ · 11–15 → ⚠️ (exceeds the ≤10 target) · **>15 → 🚩** (should split).
  Exclude lockfiles and generated code from the count.

## 3. Net lines (POL-ENG-003)

```bash
git diff --numstat <base>...HEAD \
  | grep -vE '(package-lock\.json|yarn\.lock|pnpm-lock\.yaml|poetry\.lock)$' \
  | awk '{a+=$1; d+=$2} END {print a-d}'
```

- ≤400 → ✅ · 401–800 → ⚠️ · **>800 → 🚩**. Same lockfile/generated exclusion.

## 4. Branch name — ticket id + prefix

The branch (current branch locally, or the PR head ref):

- **Ticket id** present? Match the repo's convention, e.g. `[A-Z]{2,}-\d+`
  (`GA-806`) or a bare issue number the repo uses. Missing → ⚠️.
- **Prefix** `feature/` or `feat/`? Missing → ⚠️ (e.g. bare `fix-thing`).

## 5. PR title — ticket id + clarity (PR mode only)

```bash
gh pr view <n> --json title --jq .title
```

- Carries the ticket id (or an explicit `Closes #N` in the body)? Missing → ⚠️.
- Clear & concise `type(scope): subject`? Vague ("fix stuff", "update") → ⚠️,
  and propose a concrete conventional title derived from the diff.
- Not applicable in local-branch mode (no PR) → report "n/a".

## 6. One logical concern

From the Scope lens: feature + unrelated drive-by refactor/format sweep → ⚠️,
suggest splitting. A single releasable increment → ✅.

## Reporting

Fill the **Policy checks** table in the report with each check's actual value
and ✅/⚠️/🚩. A ⚠️/🚩 never stops the review — it is a signal for the author.
