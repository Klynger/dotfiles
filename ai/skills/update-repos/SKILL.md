---
name: update-repos
description: Bring every repo in the Spoke workspace up to date. Switches clean checkouts to their default branch, pulls, removes merged worktrees and stale local branches, then runs `make sync`. Use when asked to update, refresh or clean up the workspace repos.
user-invocable: true
---

Bring the Spoke workspace up to date in one pass, without touching work in progress. Run from the workspace root (the directory holding `.spoke-workspace/`, normally `~/spoke`).

## Workflow

1. **Switch clean checkouts to their default branch**: `make main`. A checkout with uncommitted changes, or on a branch that is not fully merged, stays where it is; note those repos for the summary.
2. **Pull**: `make pull`. Fast-forwards every repo that is safe to update. Never rebase, merge or stash on the user's behalf to get a pull through; report the repo instead.
3. **Remove merged worktrees**: run the workspace's own tool, which deletes only worktrees whose branch is merged into the default branch and that carry no dirty files, stashes or open PR:

   ```bash
   bash .claude/skills/spoke-workspace-worktree-cleanup/scripts/worktree-gc.sh clean
   ```

   Never remove the worktree the current session runs in.
4. **Delete stale local branches**: `bash [skill-root]/scripts/prune-branches.sh`. It deletes, in every repo, local branches whose upstream is gone or that are fully merged into the default branch, and only when they hold no commits the remote does not. Pass `--dry-run` first when the user wants to see the list. Branches with unpushed commits, the current branch, and branches checked out in a worktree are left alone and listed.
5. **Sync the workspace**: `make sync`. Regenerates agent surfaces and validates the workspace; if it reports pending agentic update tasks, tell the user rather than running them here.
6. **Summarize** in a short table: per repo, the branch it is on and its head after the pull, worktrees removed, branches deleted, and anything skipped with the reason (dirty tree, unmerged branch, pull not fast-forwardable).

## Rules

- Read-only by default for anything that is not clearly stale: a dirty tree, a branch with unpushed commits, or a worktree with an open PR is reported, never cleaned.
- No `--force` deletes and no `git reset`; if a step needs one, stop and ask.
- If `make main`, `make pull` or `make sync` exits nonzero, show the failing lines and stop before the next step.
