#!/bin/bash

. scripts/utils.sh
. scripts/prerequisites.sh
. scripts/symlinks.sh

info "Dotfiles installation initialized…"
read -p "Install apps? [Y/n] " install_apps
read -p "Overwrite existing dotfiles? [y/n] " overwrite_dotfiles

install_apps=${install_apps:-y}

if [[ "$install_apps" == "y" ]]; then
    printf "\n"
    info "====================="
    info "Apps"
    info "====================="
    printf "\n"

    install_homebrew
    install_xcode
else
    warning "Apps won't be installed"
fi

printf "\n"
printf "\n"
info "====================="
info "Symbolic links"
info "====================="
printf "\n"

chmod +x ./scripts/symlinks.sh
if [[ "$overwrite_dotfiles" == "y" ]]; then
    warning "Deleting existing dotfiles..."
    ./scripts/symlinks.sh --delete --include-files
fi
./scripts/symlinks.sh --create

success "Dotfiles set up successfully."
