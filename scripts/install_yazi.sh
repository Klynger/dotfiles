#!/bin/bash

# Get the absolute path of the directory where the script is loaded
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. $SCRIPT_DIR/utils.sh
. $SCRIPT_DIR/install_fzf.sh

install_yazi() {
    info "💿 Installing yazi and its previewers…"

    install_fzf

    # Everything yazi/requirements.conf lists beyond fzf
    local tool formula
    for tool in yazi ffmpeg 7zz:sevenzip jq pdftoppm:poppler fd rg:ripgrep zoxide resvg magick:imagemagick mpv; do
        formula="${tool#*:}"
        tool="${tool%%:*}"
        brew_install "$tool" "$formula"
    done

    # Fonts are casks, and casks only exist on macOS; Linux gets its symbols
    # font from pacman (ttf-nerd-fonts-symbols)
    if [ "$(detect_os)" = "macos" ]; then
        if brew list --cask font-symbols-only-nerd-font &>/dev/null; then
            warning "font-symbols-only-nerd-font already installed"
        elif brew install font-symbols-only-nerd-font; then
            success "font-symbols-only-nerd-font installed"
        else
            error "font-symbols-only-nerd-font failed to install, continuing"
        fi
    fi
}

# Only run if script is executed, not sourced
if [ "$(basename "$0")" = "$(basename "${BASH_SOURCE[0]}")" ]; then
    install_yazi
fi
