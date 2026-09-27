#!/bin/bash

# Colors only when stdout is a terminal that tput knows; unattended runs
# (piped output, no TERM) get plain text instead of tput errors
if [ -t 1 ] && [ -n "$TERM" ] && tput sgr0 &>/dev/null; then
    default_color=$(tput sgr0)
    red="$(tput setaf 1)"
    yellow="$(tput setaf 3)"
    green="$(tput setaf 2)"
    blue="$(tput setaf 4)"
else
    default_color=""
    red=""
    yellow=""
    green=""
    blue=""
fi

info() {
    printf "%s==> %s%s\n" "$blue" "$1" "$default_color"
}

success() {
    printf "%s==> %s%s\n" "$green" "$1" "$default_color"
}

error() {
    printf "%s==> %s%s\n" "$red" "$1" "$default_color"
}

warning() {
    printf "%s==> %s%s\n" "$yellow" "$1" "$default_color"
}

# brew_install <command to check> [formula]
# A failed install is reported, not fatal: install.sh runs check_requirements
# at the end, which catches anything still missing
brew_install() {
    local cmd="$1" formula="${2:-$1}"

    if hash "$cmd" &>/dev/null; then
        warning "$formula already installed"
    elif brew install "$formula"; then
        success "$formula installed"
    else
        error "$formula failed to install, continuing"
    fi
}

# Prints macos, linux or unsupported. DOTFILES_OS overrides the detection,
# which lets the smoke test exercise the other OS's code path.
detect_os() {
    if [ -n "$DOTFILES_OS" ]; then
        printf "%s" "$DOTFILES_OS"
        return
    fi

    case "$(uname -s)" in
        Darwin) printf "macos" ;;
        Linux) printf "linux" ;;
        *) printf "unsupported" ;;
    esac
}
