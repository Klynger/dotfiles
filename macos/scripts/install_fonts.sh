#!/bin/bash

# Get the absolute path of the directory where the script is loaded
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. "$SCRIPT_DIR/../../scripts/utils.sh"

FONT_CASKS=(
    font-hack-nerd-font
    font-monaspace # https://github.com/githubnext/monaspace
    font-meslo-lg-nerd-font
    font-fira-code-nerd-font
)

# A failed cask is reported and skipped; install.sh sources this file, so an
# exit here would abort the whole run
install_font() {
    local cask="$1"

    if brew list --cask "$cask" &>/dev/null; then
        warning "$cask already installed"
    elif brew install --cask "$cask"; then
        success "$cask installed"
    else
        error "$cask failed to install, continuing"
        return 1
    fi
}

install_fonts() {
    info "Installing fonts…"

    local cask
    for cask in "${FONT_CASKS[@]}"; do
        install_font "$cask"
    done
}

# Only run if script is executed, not sourced
if [ "$(basename "$0")" = "$(basename "${BASH_SOURCE[0]}")" ]; then
    install_fonts
fi
