#!/bin/bash

# Get the absolute path of the directory where the script is loaded
SCRIPT_DIR="$(cd "$(dirname "$BASH_SOURCE[0]}")" && pwd)"

. $SCRIPT_DIR/utils.sh

install_wezterm() {
    info "💿 Installing Wezterm terminal emulator…"

    OS=$(detect_os)
    case $OS in
    "macos")
        if hash wezterm &>/dev/null; then
            warning "Wezterm already installed"
        else
            brew install --cask wezterm
        fi
        ;;
    "ubuntu")
        if hash wezterm &>/dev/null; then
            warning "Wezterm already installed"
        else
            sudo apt-get install wezterm
        fi
        ;;
    *)
        error "Unsupported OS for Wezterm installation: $OS"
        exit 1
        ;;
    esac

}

# Only run if script is executed, not sourced
if [ "$(basename "$0")" = "$(basename "${BASH_SOURCE[0]}")" ]; then
    install_wezterm
fi
