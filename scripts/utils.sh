#!/bin/bash

default_color=$(tput sgr 0)
red="$(tput setaf 1)"
yellow="$(tput setaf 3)"
green="$(tput setaf 2)"
blue="$(tput setaf 4)"

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
