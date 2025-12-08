#!/bin/bash

. scripts/utils.sh
. scripts/prerequisites/install.sh
. scripts/symlinks.sh
. scripts/install_fonts.sh

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

    install_homebrew
    install_xcode
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

if ! which nvim &> /dev/null; then
    echo "💿 Installing NeoVim…"
    brew install neovim && echo "✅ NeoVim installed!" || exit 1

    nvim --headless "+Lazy! sync" +qa
fi

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
