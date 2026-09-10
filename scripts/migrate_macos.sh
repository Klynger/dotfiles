#!/bin/bash

# One-shot migration of the MacBook to the macos/ split layout (phase 3 of
# the monorepo plan). Deleted once both machines are migrated; rollback is
# `git checkout pre-monorepo` plus symlinks.sh --create.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

. "$SCRIPT_DIR/utils.sh"

if [ "$(detect_os)" != "macos" ]; then
    error "This migration only runs on macOS."
    exit 1
fi

if [ -n "$(git -C "$REPO_DIR" status --porcelain)" ]; then
    error "Working tree is not clean; commit or stash before migrating."
    exit 1
fi

info "Pulling the latest main…"
git -C "$REPO_DIR" pull --ff-only || exit 1

info "Removing symlinks that point into the repo's old layout…"
removed=0
while IFS= read -r link; do
    dest="$(readlink "$link")"
    case "$dest" in
    "$REPO_DIR"/*)
        if [ ! -e "$link" ]; then
            rm "$link"
            warning "Removed dangling link: $link -> $dest"
            removed=$((removed + 1))
        fi
        ;;
    esac
done < <(find "$HOME" -maxdepth 3 -type l 2>/dev/null)

info "Removed $removed dangling links; recreating from the current confs…"
"$SCRIPT_DIR/symlinks.sh" --delete
"$SCRIPT_DIR/symlinks.sh" --create

info "Checking requirements…"
. "$SCRIPT_DIR/check_requirements.sh"
if ! check_requirements; then
    warning "Some requirements are missing; links are in place regardless."
fi

success "Migration finished. Open a new terminal and verify nvim + tmux."
