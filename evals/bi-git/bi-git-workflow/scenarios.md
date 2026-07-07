# Scenarios — bi-git-workflow

## S1: cp on a feature branch — commit and push

**Prompt:** "bi-git cp" — on branch `feature/123-add-login`, with staged
changes that implement a new login screen.

**Expected behaviors:**
- [ ] Checks that the current branch is NOT `main` or `master`
- [ ] Constructs a commit message containing the ticket id (`123`) in
      `type(scope): subject` format per git-rule.md
- [ ] Commits the staged changes (or proposes to stage and commit)
- [ ] Pushes the branch to `origin`
- [ ] Does NOT open a PR

## S2: cp on main — branch guard

**Prompt:** "bi-git cp" — while on the `main` branch.

**Expected behaviors:**
- [ ] Refuses to commit and push on `main`
- [ ] Explains that `main` is a protected branch
- [ ] Asks the user to create a feature branch first
- [ ] Does NOT commit or push anything

## S3: pr on a feature branch — create PR with ticket comment

**Prompt:** "bi-git pr" — on branch `feature/456-refactor-cart`, after
changes have already been pushed; the linked ticket is issue #456.

**Expected behaviors:**
- [ ] Checks the current branch is NOT `main` or `master`
- [ ] Gathers a summary of changes (reads diff or commit log)
- [ ] Creates a PR whose description follows the template (What/Why/How/Testing)
      and contains a summary of the changes
- [ ] After PR creation, posts the PR link as a comment on issue #456
- [ ] Does NOT commit or push new code during this step

## S4: pr on master — branch guard

**Prompt:** "bi-git pr" — while on the `master` branch.

**Expected behaviors:**
- [ ] Refuses to create a PR from `master`
- [ ] Explains that the working branch must be a feature branch
- [ ] Asks the user to create or switch to a feature branch first
- [ ] Does NOT create a PR

## S5: cp — commit message must contain ticket id

**Prompt:** "bi-git cp" — on branch `feature/789-dark-mode`, user provides
commit message "update styles" (no ticket id).

**Expected behaviors:**
- [ ] Detects that the proposed message lacks the ticket id (`789`)
- [ ] Rewrites or proposes a message containing `789`, e.g.
      `feat(ui): add dark mode [#789]` or `feat(ui): add dark mode (#789)`
- [ ] Does NOT commit with the bare message "update styles"

## S6: Branch not linked to ticket Development section

**Prompt:** "bi-git cp" — on branch `feature/101-search`, but the branch
has not been linked to issue #101 in the Development section yet.

**Expected behaviors:**
- [ ] Reminds the user to link the working branch to the ticket's Development
      section (GitHub issue sidebar) before or after pushing
- [ ] Still proceeds with commit + push if the user confirms
