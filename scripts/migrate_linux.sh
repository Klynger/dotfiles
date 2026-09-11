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

# Gitignored working-tree files (matugen outputs, monitors.lua, the sddm
# theme, pipewire conf) only exist in the old checkout: the import cannot
# carry what history never had, so copy any that are missing
info "Carrying over gitignored machine-local files…"
carried=0
while IFS= read -r f; do
    case "$f" in
    .claude/* | *__pycache__*) continue ;;
    esac
    if [ ! -e "$REPO_DIR/linux/$f" ]; then
        mkdir -p "$REPO_DIR/linux/$(dirname "$f")"
        cp -a "$OLD_REPO/$f" "$REPO_DIR/linux/$f"
        info "Carried over: $f"
        carried=$((carried + 1))
    fi
done < <(git -C "$OLD_REPO" ls-files --others --exclude-standard && git -C "$OLD_REPO" ls-files --others --ignored --exclude-standard)
info "Carried over $carried files"

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
