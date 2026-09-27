#!/bin/bash

# Seeds the matugen-generated theme files on a machine that has never run
# matugen (hypr colors.lua, waybar/gtk/rofi css, the sddm Main.qml, ...).
# They are all gitignored, and without them the first Hyprland session loads
# half-broken: looknfeel.lua requires colors.lua and waybar imports its css.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. "$SCRIPT_DIR/utils.sh"

WALLPAPER_DIR="$HOME/Pictures/Wallpapers/current"
SDDM_THEME_DIR="$SCRIPT_DIR/../sddm/material-you"
# Used when no wallpaper exists yet; change-wallpaper regenerates everything
# from a real image later
SEED_COLOR="#7aa2f7"

seed_theme() {
    if [ -e "$HOME/.config/hypr/colors.lua" ]; then
        warning "Theme files already generated"
        return
    fi

    if ! hash matugen &>/dev/null; then
        error "matugen is not installed; run change-wallpaper once it is"
        return 1
    fi

    # Post-hooks (hyprctl reload, swaync-client, the sudo sddm copy) fail
    # outside a live session; that is fine, the generated files are the point
    mkdir -p "$WALLPAPER_DIR"
    local wallpaper
    wallpaper="$(find "$WALLPAPER_DIR" -type f 2>/dev/null | head -1)"
    if [ -n "$wallpaper" ]; then
        info "Generating theme from $(basename "$wallpaper")…"
        matugen image "$wallpaper" -c "$HOME/.config/matugen/config.toml" --source-color-index 0
    else
        info "No wallpaper in $WALLPAPER_DIR yet; seeding theme from $SEED_COLOR"
        matugen color hex "$SEED_COLOR" -c "$HOME/.config/matugen/config.toml"
    fi

    # The sddm background is normally written by pick-lock-wallpaper
    if [ -n "$wallpaper" ] && [ ! -e "$SDDM_THEME_DIR/background.jpg" ] && hash magick &>/dev/null; then
        magick "$wallpaper" "$SDDM_THEME_DIR/background.jpg"
        info "Seeded the sddm lock background from the wallpaper"
    fi
}

# Only run if script is executed, not sourced
if [ "$(basename "$0")" = "$(basename "${BASH_SOURCE[0]}")" ]; then
    seed_theme
fi
