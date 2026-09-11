#!/bin/bash

# One-shot migration of the Linux machine from the hyprland-desktop-config
# checkout to dotfiles/linux/ (phase 4 of the monorepo plan). Deleted once
# both machines are migrated; rollback is the untouched old checkout plus
# its pre-monorepo tag.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
OLD_REPO="$HOME/dev/hyprland-desktop-config"

. "$SCRIPT_DIR/utils.sh"

if [ "$(detect_os)" != "linux" ]; then
    error "This migration only runs on Linux."
    exit 1
fi

if [ ! -d "$REPO_DIR/linux" ]; then
    error "linux/ not found in the checkout; merge the import first."
    exit 1
fi

if [ -n "$(git -C "$REPO_DIR" status --porcelain)" ]; then
    error "Working tree is not clean; commit or stash before migrating."
    exit 1
fi

info "Removing symlinks that point into $OLD_REPO…"
removed=0
while IFS= read -r link; do
    dest="$(readlink "$link")"
    case "$dest" in
    "$OLD_REPO"/*)
        rm "$link"
        warning "Removed: $link -> $dest"
        removed=$((removed + 1))
        ;;
    esac
done < <(find "$HOME" -maxdepth 3 -type l 2>/dev/null)

info "Removed $removed links; recreating from symlinks/general.conf + linux.conf…"
(cd "$REPO_DIR" && ./scripts/symlinks.sh --create)

# The pipewire conf is machine-local and gitignored (like hypr/monitors.lua),
# so it only exists in the old working tree and must be carried over by hand
old_pw="$OLD_REPO/pipewire/pipewire-pulse.conf.d/custom-modules.conf"
new_pw="$REPO_DIR/linux/pipewire/pipewire-pulse.conf.d/custom-modules.conf"
if [ -f "$old_pw" ] && [ ! -f "$new_pw" ]; then
    cp "$old_pw" "$new_pw"
    info "Carried over machine-local pipewire config"
fi

info "Re-running the copy-based steps…"
"$REPO_DIR/linux/scripts/copy-base-files.sh"
"$REPO_DIR/linux/scripts/install-binaries.sh"
warning "Root copies need sudo; run when convenient:"
warning "  sudo $REPO_DIR/linux/scripts/copies-root.sh --create"

if command -v hyprctl >/dev/null 2>&1 && [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
    info "Reloading Hyprland…"
    hyprctl reload >/dev/null && success "Hyprland reloaded"
    if pgrep -x waybar >/dev/null; then
        info "Restarting waybar…"
        pkill -x waybar && sleep 1
        (setsid "$HOME/.local/bin/launch-waybar" >/dev/null 2>&1 &)
    fi
else
    warning "No live Hyprland session detected; skipping reload."
fi

success "Migration finished. Keep $OLD_REPO untouched until everything is verified."
