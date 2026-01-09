#!/bin/bash

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

install_powerlevel10k() {
    info "💿 Installing Powerlevel10k…"
    if brew list powerlevel10k &>/dev/null; then
        warning "Powerlevel10k already installed"
    else
        brew install romkatv/powerlevel10k/powerlevel10k
    fi

    if ! grep -q "powerlevel10k" "$HOME/.zshrc" 2>/dev/null; then
        echo 'source $(brew --prefix)/share/powerlevel10k/powerlevel10k.zsh-theme' >>"$HOME/.zshrc"
        info "Added Powerlevel10k to .zshrc"
    fi
}

install_zsh_autosuggestions() {
    info "💿 Installing Zsh autosuggestions…"
    if brew list zsh-autosuggestions &>/dev/null; then
        warning "Zsh autosuggestions already installed"
    else
        brew install zsh-autosuggestions
    fi

    improve_autosuggestions_history
}

improve_autosuggestions_history() {
    info "Improving history…"

    if ! grep -q "HISTORY_SETUP" "$HOME/.zshrc" 2>/dev/null; then
        echo '' >>"$HOME/.zshrc"
        echo '# HISTORY_SETUP' >>"$HOME/.zshrc"
        echo 'HISTFILE=$HOME/.zsh_history' >>"$HOME/.zshrc"
        echo 'HISTSIZE=1000' >>"$HOME/.zshrc"
        echo 'SAVEHIST=1000' >>"$HOME/.zshrc"
        echo 'setopt share_history' >>"$HOME/.zshrc"
        echo 'setopt hist_expire_dups_first' >>"$HOME/.zshrc"
        echo 'setopt hist_ignore_dups' >>"$HOME/.zshrc"
        echo 'setopt hist_verify' >>"$HOME/.zshrc"

        echo "bindkey '^[[A' history-search-backward" >>"$HOME/.zshrc"
        echo "bindkey '^[[B' history-search-forward" >>"$HOME/.zshrc"
        echo '# END_HISTORY_SETUP' >>"$HOME/.zshrc"
        info "Added history config to .zshrc"
    else
        warning "Zsh history already set"
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
