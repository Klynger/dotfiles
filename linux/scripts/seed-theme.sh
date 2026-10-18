#!/bin/bash

# Seeds the per-machine theme files the repo gitignores: the GTK colors.css
# copies (mode-dependent, later rewritten by toggle-theme-mode), the
# hyprlock wallpaper conf and the sddm background. Without them a fresh
# machine's first session loads with unthemed GTK apps and a bare lock
# screen.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. "$SCRIPT_DIR/utils.sh"

WALLPAPER_DIR="$HOME/Pictures/Wallpapers/current"
SDDM_THEME_DIR="$SCRIPT_DIR/../sddm/glass"
GTK3_DIR="$SCRIPT_DIR/../gtk-3.0"
GTK4_DIR="$SCRIPT_DIR/../gtk-4.0"
LOCK_WALLPAPER_CONF="$HOME/.cache/hyprlock-wallpaper.conf"

seed_theme() {
    # GTK palette: default to dark, toggle-theme-mode swaps it afterwards
    if [ ! -e "$GTK3_DIR/colors.css" ]; then
        cp "$GTK3_DIR/colors-dark.css" "$GTK3_DIR/colors.css"
        info "Seeded the GTK3 colors"
    fi
    if [ ! -e "$GTK4_DIR/colors.css" ]; then
        cp "$GTK3_DIR/colors-dark.css" "$GTK4_DIR/colors.css"
        info "Seeded the GTK4 colors"
    fi

    mkdir -p "$WALLPAPER_DIR"
    local wallpaper
    wallpaper="$(find "$WALLPAPER_DIR" -type f 2>/dev/null | head -1)"
    if [ -z "$wallpaper" ]; then
        warning "No wallpaper in $WALLPAPER_DIR yet; skipped the lock and sddm backgrounds"
        return
    fi

    # The hyprlock fallback sources this conf unconditionally
    if [ ! -e "$LOCK_WALLPAPER_CONF" ]; then
        mkdir -p "$(dirname "$LOCK_WALLPAPER_CONF")"
        echo "\$lock_wallpaper = $wallpaper" >"$LOCK_WALLPAPER_CONF"
        info "Seeded the hyprlock wallpaper"
    fi

    # Copied to /usr/share with the rest of the sddm theme by copies-root.sh
    if [ ! -e "$SDDM_THEME_DIR/background.jpg" ] && hash magick &>/dev/null; then
        magick "$wallpaper" "$SDDM_THEME_DIR/background.jpg"
        info "Seeded the sddm background from the wallpaper"
    fi
}

# Only run if script is executed, not sourced
if [ "$(basename "$0")" = "$(basename "${BASH_SOURCE[0]}")" ]; then
    seed_theme
fi
