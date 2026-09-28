#!/bin/bash
# Delete stale local branches in every repo under the workspace root.
#
# A branch is stale when its upstream is gone or it is fully merged into the
# default branch, and it holds no commit the remote does not have. The current
# branch and branches checked out in a worktree are never touched.
#
# Usage: prune-branches.sh [--dry-run] [workspace-root]
set -u

dry_run=0
root=""
for arg in "$@"; do
  case "$arg" in
    --dry-run) dry_run=1 ;;
    *) root="$arg" ;;
  esac
done
root="${root:-$(pwd)}"

for dir in "$root"/*/ "$root"/.spoke-workspace/; do
  repo="${dir%/}"
  [ -d "$repo/.git" ] || continue
  name=$(basename "$repo")
  default=$(git -C "$repo" symbolic-ref -q --short refs/remotes/origin/HEAD 2>/dev/null | sed 's#^origin/##')
  [ -n "$default" ] || default=main
  git -C "$repo" fetch -q --prune origin 2>/dev/null || { echo "$name: fetch failed, skipped"; continue; }
  current=$(git -C "$repo" branch --show-current)
  checked_out=$(git -C "$repo" worktree list --porcelain | sed -n 's#^branch refs/heads/##p')

  git -C "$repo" for-each-ref --format='%(refname:short) %(upstream:short) %(upstream:track)' refs/heads |
  while read -r branch upstream track; do
    [ "$branch" = "$default" ] && continue
    [ "$branch" = "$current" ] && continue
    if printf '%s\n' "$checked_out" | grep -qx "$branch"; then
      echo "$name: $branch kept, checked out in a worktree"
      continue
    fi
    stale=0
    if [ "$track" = "[gone]" ]; then
      stale=1
    elif git -C "$repo" merge-base --is-ancestor "$branch" "origin/$default" 2>/dev/null; then
      stale=1
    fi
    [ "$stale" = 1 ] || continue
    # A commit the remote never received is work; keep the branch.
    if [ -n "$upstream" ] && [ "$track" != "[gone]" ] && [ "$(git -C "$repo" rev-list --count "$upstream..$branch" 2>/dev/null)" != "0" ]; then
      echo "$name: $branch kept, unpushed commits"
      continue
    fi
    if ! git -C "$repo" merge-base --is-ancestor "$branch" "origin/$default" 2>/dev/null && [ "$track" = "[gone]" ]; then
      # Upstream gone and not merged as-is: a squash merge leaves this shape.
      # A merged pull request for the branch settles it; without one, keep
      # the branch unless every patch is already upstream.
      merged_pr=""
      if command -v gh >/dev/null 2>&1; then
        merged_pr=$(cd "$repo" && gh pr list --head "$branch" --state merged --json number --jq '.[0].number' 2>/dev/null)
      fi
      if [ -z "$merged_pr" ] && [ -n "$(git -C "$repo" cherry "origin/$default" "$branch" 2>/dev/null | grep '^+')" ]; then
        echo "$name: $branch kept, upstream gone but no merged PR and patches not on $default"
        continue
      fi
    fi
    if [ "$dry_run" = 1 ]; then
      echo "$name: $branch would be deleted"
    else
      git -C "$repo" branch -D -q "$branch" && echo "$name: $branch deleted"
    fi
  done
done
