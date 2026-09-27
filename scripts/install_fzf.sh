#!/bin/bash

# Get the absolute path of the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "$BASH_SOURCE[0]}")" && pwd)"

. $SCRIPT_DIR/utils.sh

install_fzf() {
    info "Installing fzf…"
    brew_install fzf
}

install_bat() {
    info "Installing bat…"
    # CLI tools come from brew on macOS and linuxbrew alike
    brew_install bat
}

# Only run if script is executed, not sourced
if [ "$(basename "$0")" = "$(basename "${BASH_SOURCE[0]}")" ]; then
    install_fzf
    install_bat
fi
