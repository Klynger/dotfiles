#!/bin/bash

. scripts/utils.sh
. scripts/prerequisites/install.sh
. scripts/install_kitty.sh
. scripts/install_fzf.sh
. scripts/symlinks.sh
. scripts/install_fonts.sh
. scripts/install_wezterm.sh
. scripts/install_yazi.sh
. scripts/install_tmux.sh
. scripts/install_nvim.sh

info "Dotfiles installation initialized…"
read -p "Install apps? [Y/n] " install_apps
read -p "Overwrite existing dotfiles? [y/n] " overwrite_dotfiles
read -p "Install fonts? [Y/n] " install_fonts_opt

install_apps=${install_apps:-y}
install_fonts_opt=${install_fonts_opt:-y}

if [[ "$install_apps" == "y" ]]; then
    printf "\n"
    info "====================="
    info "Apps"
    info "====================="
    printf "\n"

    install_prerequisites
    install_fzf
    install_wezterm
    install_yazi
    install_zsh_and_plugins
    install_tmux

else
    warning "Apps won't be installed"
fi

if [[ $install_fonts_opt == "y" ]]; then
    printf "\n"
    info "====================="
    info "Fonts"
    info "====================="
    printf "\n"

    install_fonts
fi

install_nvim

printf "\n"
printf "\n"
info "====================="
info "Symbolic links"
info "====================="
printf "\n"

chmod +x ./scripts/symlinks.sh
if [[ "$overwrite_dotfiles" == "y" ]]; then
    warning "Deleting existing dotfiles…"
    ./scripts/symlinks.sh --delete --include-files
fi
./scripts/symlinks.sh --create

success "Dotfiles set up successfully."
