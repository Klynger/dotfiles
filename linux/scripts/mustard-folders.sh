#!/bin/bash

# Papirus has no mustard folder color, so this recolors its yellow set
# into user-local overrides (~/.local/share/icons), where they shadow the
# system theme without sudo and survive papirus-icon-theme updates.
# Re-run after a Papirus update adds new folder icons.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/utils.sh"

set -euo pipefail

# Papirus yellow -> mustard, body and shade
body_from="#f9bd30"
body_to="#cfa53a"
shade_from="#e19d00"
shade_to="#a67f1e"

generate_mustard_folders() {
    local theme src_root dst_root count
    for theme in Papirus-Dark Papirus-Light; do
        src_root="/usr/share/icons/$theme"
        dst_root="$HOME/.local/share/icons/$theme"
        if [ ! -d "$src_root" ]; then
            warning "$theme is not installed, skipping"
            continue
        fi

        count=0
        while IFS= read -r src; do
            local rel dst
            rel="${src#"$src_root"/}"
            dst="$dst_root/${rel//-yellow/}"
            mkdir -p "$(dirname "$dst")"
            sed -e "s/$body_from/$body_to/g" -e "s/$shade_from/$shade_to/g" \
                "$src" > "$dst"
            count=$((count + 1))
        done < <(find -L "$src_root" -name 'folder-yellow*.svg')

        success "$theme: $count mustard folder icons written to $dst_root"
    done
}

if [ "$0" = "${BASH_SOURCE[0]}" ]; then
    generate_mustard_folders
fi
