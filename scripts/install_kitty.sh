#!/bin/bash

# Get the absolute path of the directory where the script is loaded
SCRIPT_DIR="$(cd "$(dirname "$BASH_SOURCE[0]}")" && pwd)"

. $SCRIPT_DIR/utils.sh

install_kitty() {
    info "Installing Kitty terminal emulator…"

    if hash kitty &>/dev/null; then
        warning "Kitty already installed"
    else
        brew install --cask kitty
    fi
}

# Only run if script is executed, not sourced
if [ "$(basename "$0")" = "$(basename "${BASH_SOURCE[0]}")" ]; then
    install_kitty
fi
