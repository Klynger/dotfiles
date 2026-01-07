#!/bin/bash

# Get the absolute path of the directory where the script is loaded
SCRIPT_DIR="$(cd "$(dirname "$BASH_SOURCE[0]}")" && pwd)"

. $SCRIPT_DIR/utils.sh

install_kitty() {
    info "💿 Installing Kitty terminal emulator…"

    OS=$(detect_os)
    case $OS in
    "macos")
        if hash kitty &>/dev/null; then
            warning "Kitty already installed"
        else
            brew install --cask kitty
        fi
        ;;
    "ubuntu")
        if hash kitty &>/dev/null; then
            warning "Kitty already installed"
        else
            sudo apt-get install kitty
        fi
        ;;
    *)
        error "Unsupported OS for Kitty installation: $OS"
        exit 1
        ;;
    esac
}

# Only run if script is executed, not sourced
if [ "$(basename "$0")" = "$(basename "${BASH_SOURCE[0]}")" ]; then
    install_kitty
fi
