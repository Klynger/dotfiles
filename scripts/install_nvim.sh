#!/bin/bash

# Get the absolute path of the directory where the script is loaded
SCRIPT_DIR="$(cd "$(dirname "$BASH_SOURCE[0]}")" && pwd)"

. $SCRIPT_DIR/utils.sh

# Failures are reported, not fatal: install.sh sources this file and the
# requirements check after it catches anything still missing
install_nvim() {
    info "💿 Installing NeoVim…"

    if hash nvim &>/dev/null; then
        warning "NeoVim already installed"
    elif brew install neovim; then
        success "NeoVim installed"
    else
        error "NeoVim failed to install, continuing"
    fi

    info "💿 Installing shfmt (used by the NeoVim config)…"
    if hash shfmt &>/dev/null; then
        warning "shfmt already installed"
    elif brew install shfmt; then
        success "shfmt installed"
    else
        error "shfmt failed to install, continuing"
    fi
}

# Only run if script is executed, not sourced
if [ "$(basename "$0")" = "$(basename "${BASH_SOURCE[0]}")" ]; then
    install_nvim
fi
