#!/bin/bash

. scripts/utils.sh
. scripts/prerequisites.sh

info "Dotfiles installation initialized…"
read -p "Install apps? [Y/n] " install_apps

install_apps=${install_apps:-y}

if [[ "$install_apps" == "y" ]]; then
    printf "\n"
    info "====================="
    info "Apps"
    info "====================="

    install_homebrew
    install_xcode
fi
