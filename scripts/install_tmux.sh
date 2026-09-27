#!/bin/bash

# Get the absolute path of the directory where the script is loaded
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TPM_DIR="$SCRIPT_DIR/../tmux/plugins/tpm"

. $SCRIPT_DIR/utils.sh

install_tmux() {
    info "💿 Installing Tmux…"
    brew_install tmux

    # tmux/plugins is gitignored and symlinked to ~/.config/tmux/plugins, so
    # tpm is cloned into the repo copy and the symlink picks it up later
    if [ -d "$TPM_DIR" ]; then
        warning "tpm already installed"
    elif git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"; then
        success "tpm installed"
    else
        error "tpm failed to install, continuing"
    fi
}

# Needs ~/.tmux.conf in place, tpm reads the @plugin list from it, so this
# runs after the symlinks are created
install_tmux_plugins() {
    info "💿 Installing tmux plugins…"
    "$TPM_DIR/bin/install_plugins"
}

# Only run if script is executed, not sourced
if [ "$(basename "$0")" = "$(basename "${BASH_SOURCE[0]}")" ]; then
    install_tmux
fi
