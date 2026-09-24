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

# Every prompt can be answered up front, which is what a fresh-machine test
# or an unattended run needs:
#   ./install.sh --yes        take the default for every prompt
#   DOTFILES_INSTALL_APPS=n   answer one prompt (see the ask calls below)
# Piped stdin also counts as unattended.
NON_INTERACTIVE=false
for arg in "$@"; do
    case "$arg" in
        -y | --yes) NON_INTERACTIVE=true ;;
        -h | --help)
            echo "Usage: $0 [--yes]"
            echo "  DOTFILES_INSTALL_APPS, DOTFILES_OVERWRITE_DOTFILES, DOTFILES_INSTALL_FONTS,"
            echo "  DOTFILES_IGNORE_REQUIREMENTS: y or n, pre-answer the matching prompt"
            exit 0
            ;;
        *)
            error "Unknown argument: $arg"
            exit 1
            ;;
    esac
done
if [ ! -t 0 ]; then
    NON_INTERACTIVE=true
fi

# ask <variable> <env override> <prompt> <default>
ask() {
    local var="$1" env_name="$2" prompt="$3" default="$4"
    local value="${!env_name}"

    if [ -z "$value" ]; then
        if [ "$NON_INTERACTIVE" = true ]; then
            value="$default"
        else
            read -p "$prompt" value
            value="${value:-$default}"
        fi
    fi

    printf -v "$var" "%s" "$(printf "%s" "$value" | tr '[:upper:]' '[:lower:]')"
}

info "Dotfiles installation initialized ($OS)…"
ask install_apps DOTFILES_INSTALL_APPS "Install apps? [Y/n] " y
ask overwrite_dotfiles DOTFILES_OVERWRITE_DOTFILES "Overwrite existing dotfiles? [y/N] " n
if [ "$OS" = "macos" ]; then
    ask install_fonts_opt DOTFILES_INSTALL_FONTS "Install fonts? [Y/n] " y
fi

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
    ask continue_anyway DOTFILES_IGNORE_REQUIREMENTS "Create the symlinks anyway? [y/N] " n
    if [[ "$continue_anyway" != "y" ]]; then
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
