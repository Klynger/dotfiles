#!/bin/bash

. scripts/utils.sh
. scripts/install_fzf.sh
. scripts/symlinks.sh
. scripts/install_yazi.sh
. scripts/install_tmux.sh
. scripts/install_nvim.sh
. scripts/install_zsh.sh
. scripts/check_requirements.sh

OS=$(detect_os)
if [ "$OS" = "unsupported" ]; then
    error "Unsupported OS: $(uname -s)"
    exit 1
fi

if [ "$OS" = "macos" ]; then
    . macos/scripts/prerequisites/install.sh
    . macos/scripts/install_fonts.sh
    . macos/scripts/install_wezterm.sh
fi

info "Dotfiles installation initialized ($OS)…"
read -p "Install apps? [Y/n] " install_apps
read -p "Overwrite existing dotfiles? [y/n] " overwrite_dotfiles
if [ "$OS" = "macos" ]; then
    read -p "Install fonts? [Y/n] " install_fonts_opt
    install_fonts_opt=${install_fonts_opt:-y}
fi

install_apps=${install_apps:-y}

if [[ "$install_apps" == "y" ]]; then
    printf "\n"
    info "====================="
    info "Apps"
    info "====================="
    printf "\n"

    # CLI tools install through brew on both OSes (Homebrew on macOS,
    # linuxbrew on Linux). Casks and desktop packages are per-OS: macOS
    # handles them here, Linux leaves them to pacman.
    if [ "$OS" = "macos" ]; then
        install_macos_prerequisites
        install_wezterm
    fi

    install_fzf
    install_yazi
    install_zsh_and_plugins
    install_tmux

else
    warning "Apps won't be installed"
fi

if [[ "$OS" == "macos" && "$install_fonts_opt" == "y" ]]; then
    printf "\n"
    info "====================="
    info "Fonts"
    info "====================="
    printf "\n"

    install_fonts
fi

install_nvim

printf "\n"
info "====================="
info "Requirements"
info "====================="
printf "\n"

if ! check_requirements; then
    printf "\n"
    warning "Requirements not met:"
    for failure in "${REQUIREMENT_FAILURES[@]}"; do
        error "  ✗ $failure"
    done
    printf "\n"
    read -p "Create the symlinks anyway? [y/N] " continue_anyway
    if [[ "${continue_anyway:-n}" != "y" ]]; then
        error "Aborting before creating symlinks."
        exit 1
    fi
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

install_tmux_plugins

success "Dotfiles set up successfully."
