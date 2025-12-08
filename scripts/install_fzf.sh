#!/bin/bash

# Get the absolute path of the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "$BASH_SOURCE[0]}")" && pwd)"

. $SCRIPT_DIR/utils.sh

install_fzf() {
    info "Installing fzf…"

    if hash fzf &>/dev/null; then
        warning "fzf already installed"
    else
        brew install fzf
    fi

    warning "Remember to check if you need to add something to .zshrc"
}

install_bat() {
    info "Installing bat…"

    if hash bat &>/dev/null; then
        warning "bat already installed"
    else
        brew install bat
    fi
}

# Only run if script is executed, not sourced
if [ "$(basename "$0")" = "$(basename "${BASH_SOURCE[0]}")" ]; then
    install_fzf
    install_bat
fi

