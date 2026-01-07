#!/bin/bash

# Get the absolute path of the directory where the script is loaded
SCRIPT_DIR="$(cd "$(dirname "$BASH_SOURCE[0]}")" && pwd)"

. $SCRIPT_DIR/utils.sh

install_nvim() {
    info "💿 Installing NeoVim…"

    OS=$(detect_os)

    case $OS in
    "macos")
        if ! which nvim &>/dev/null; then
            brew install neovim && echo "✅ NeoVim installed!" || exit 1
        else
            warning "NeoVim already installed"
        fi
        ;;
    "ubuntu")
        if ! which nvim &>/dev/null; then
            sudo apt install -y neovim && echo "✅ NeoVim installed!" || exit 1
        else
            warning "NeoVim already installed"
        fi
        ;;
    *)
        error "Unsupported OS for NeoVim installation: $OS"
        exit 1
        ;;
    esac

    info "💿 Installing shfmt…"
    info "shfmt is used in the NeoVim config"
    case $OS in
    "macos")
        if ! which shfmt &>/dev/null; then
            brew install shfmt && echo "✅ shfmt installed!" || exit 1
        else
            warning "shfmt already installed"
        fi
        ;;
    "ubuntu")
        if ! which shfmt &>/dev/null; then
            sudo snap install shfmt && echo "✅ shfmt installed!" || exit 1
        else
            warning "shfmt already installed"
        fi
        ;;
}

# Only run if script is executed, not sourced
if [ "$(basename "$0")" = "$(basename "${BASH_SOURCE[0]}")" ]; then
    install_nvim
fi
