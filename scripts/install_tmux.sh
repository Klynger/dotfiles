#!/bin/bash

# Get the absolute path of the directory where the script is loaded
SCRIPT_DIR="$(cd "$(dirname "$BASH_SOURCE[0]}")" && pwd)"

. $SCRIPT_DIR/utils.sh

install_tmux() {
    info "💿 Installing Tmux…"

    OS=$(detect_os)
    case $OS in
    "macos")
        if hash tmux &>/dev/null; then
            warning "Tmux already installed"
        else
            brew install tmux
            # TODO: Check if this is working.
            # It seems that it is cloning the repo, but the symlink doesn't
            # exist yet.
            git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm
        fi
        ;;
    "ubuntu")
        if hash tmux &>/dev/null; then
            warning "Tmux already installed"
        else
            sudo apt-get install tmux
            git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm
        fi
        ;;
    *)
        error "Unsupported OS for Tmux installation: $OS"
        exit 1
        ;;
    esac
}

# Only run if script is executed, not sourced
if [ "$(basename "$0")" = "$(basename "${BASH_SOURCE[0]}")" ]; then
    install_tmux
fi

