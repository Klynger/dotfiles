#!/bin/bash

# Get the absolute path of the directory where the script is loaded
SCRIPT_DIR="$(cd "$(dirname "$BASH_SOURCE[0]}")" && pwd)"

. $SCRIPT_DIR/utils.sh

install_nvim() {
    info "💿 Installing NeoVim…"

    if ! which nvim &>/dev/null; then
        brew install neovim && echo "✅ NeoVim installed!" || exit 1

        nvim --headless "+Lazy! sync" +qa
    else
        warning "NeoVim already installed"
    fi

    info "💿 Installing shfmt…"
    info "shfmt is used in the NeoVim config"
    if ! which shfmt &>/dev/null; then
        brew install shfmt && echo "✅ shfmt installed!" || exit 1
    else
        warning "shfmt already installed"
    fi
}

# Only run if script is executed, not sourced
if [ "$(basename "$0")" = "$(basename "${BASH_SOURCE[0]}")" ]; then
    install_nvim
fi
