#!/bin/bash

# Installs zsh, Oh My Zsh and the brew-provided theme and plugins that
# zsh/.zshrc sources. Nothing here writes to .zshrc; that file is tracked.
# Get the absolute path of the directory where the script is loaded
SCRIPT_DIR="$(cd "$(dirname "$BASH_SOURCE[0]}")" && pwd)"

. $SCRIPT_DIR/utils.sh

install_zsh() {
    info "💿 Installing Zsh…"
    if hash zsh &>/dev/null; then
        warning "Zsh already installed"
    else
        brew install zsh
    fi
}

install_oh_my_zsh() {
    info "💿 Installing Oh My Zsh…"
    if [ -d "$HOME/.oh-my-zsh" ]; then
        warning "Oh My Zsh already installed"
        return
    fi

    # Unattended: no shell switch, no zsh exec at the end, and an existing
    # .zshrc is left alone (the installer writes its template otherwise)
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
}

install_powerlevel10k() {
    info "💿 Installing Powerlevel10k…"
    if brew list powerlevel10k &>/dev/null; then
        warning "Powerlevel10k already installed"
    else
        brew install romkatv/powerlevel10k/powerlevel10k
    fi
}

install_zsh_autosuggestions() {
    info "💿 Installing Zsh autosuggestions…"
    if brew list zsh-autosuggestions &>/dev/null; then
        warning "Zsh autosuggestions already installed"
    else
        brew install zsh-autosuggestions
    fi
}

install_zsh_syntax_highlighting() {
    info "💿 Installing Zsh syntax highlighting…"
    if brew list zsh-syntax-highlighting &>/dev/null; then
        warning "Zsh syntax highlighting already installed"
    else
        brew install zsh-syntax-highlighting
    fi
}

install_zsh_and_plugins() {
    install_zsh
    install_oh_my_zsh
    install_powerlevel10k
    install_zsh_autosuggestions
    install_zsh_syntax_highlighting
}

# Only run if script is executed, not sourced
if [ "$(basename "$0")" = "$(basename "${BASH_SOURCE[0]}")" ]; then
    install_zsh_and_plugins
fi
