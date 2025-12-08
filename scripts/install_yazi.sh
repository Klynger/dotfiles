#!/bin/bash

# Get the absolute path of the directory where the script is loaded
SCRIPT_DIR="$(cd "$(dirname "$BASH_SOURCE[0]}")" && pwd)"

. $SCRIPT_DIR/utils.sh
. $SCRIPT_DIR/install_fzf.sh

install_mpv() {
    info "Installing mpv…"

    if hash mpv &>/dev/null; then
        warning "mpv already installed"
    else
        brew install mpv
    fi
}

install_yazi() {
    info "Installing yazi…"

    if hash yazi &>/dev/null; then
        warning "yazi already installed"
    else
       install_fzf 
       brew install yazi ffmpeg sevenzip jq poppler fd ripgrep zoxide resvg imagemagick font-symbols-only-nerd-font
    fi
}

# Only run if script is executed, not sourced
if [ "$(basename "$0")" = "$(basename "${BASH_SOURCE[0]}")" ]; then
    install_fzf
    install_mpv
    install_yazi
fi

