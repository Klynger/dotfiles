#!/bin/bash

# Installs zsh, Oh My Zsh and the brew-provided theme and plugins that
# zsh/.zshrc sources. Nothing here writes to .zshrc; that file is tracked.
# Get the absolute path of the directory where the script is loaded
SCRIPT_DIR="$(cd "$(dirname "$BASH_SOURCE[0]}")" && pwd)"

. $SCRIPT_DIR/utils.sh

install_zsh() {
    info "💿 Installing Zsh…"
    brew_install zsh
}

# For formulae that install no command (theme and plugins sourced by .zshrc);
# failures are reported, not fatal, like brew_install
install_zsh_extra() {
    local formula="$1"

    if brew list "$formula" &>/dev/null; then
        warning "$formula already installed"
    elif brew install "$formula"; then
        success "$formula installed"
    else
        error "$formula failed to install, continuing"
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
    local had_zshrc=false
    [ -e "$HOME/.zshrc" ] && had_zshrc=true

    # ZSH is pinned because CachyOS's default zsh exports
    # ZSH=/usr/share/oh-my-zsh (its packaged copy), and the installer
    # refuses to install over a ZSH directory it did not create
    if ! ZSH="$HOME/.oh-my-zsh" RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended; then
        error "Oh My Zsh failed to install, continuing"
        return
    fi

    # On a fresh machine there is no .zshrc to keep, so the installer writes
    # its template; that would block the symlink to the tracked zsh/.zshrc
    if [ "$had_zshrc" = false ] && [ -f "$HOME/.zshrc" ]; then
        rm "$HOME/.zshrc"
        info "Removed the Oh My Zsh template .zshrc; the tracked one gets linked later"
    fi
}

install_zsh_and_plugins() {
    install_zsh
    install_oh_my_zsh

    info "💿 Installing the zsh theme and plugins…"
    # powerlevel10k comes from homebrew-core: the romkatv tap needs
    # `brew trust` on Homebrew 7, which an unattended run cannot give
    local formula
    for formula in powerlevel10k zsh-autosuggestions zsh-syntax-highlighting; do
        install_zsh_extra "$formula"
    done
}

# Only run if script is executed, not sourced
if [ "$(basename "$0")" = "$(basename "${BASH_SOURCE[0]}")" ]; then
    install_zsh_and_plugins
fi
