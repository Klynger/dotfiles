#!/bin/bash

# Get the absolute path of the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. "$SCRIPT_DIR/../../../scripts/utils.sh"

install_xcode() {
    info "Installing Apples's CLI tools (prerequisites for Git and Homebrew)…"
    if xcode-select -p >/dev/null; then
        warning "xcode is already installed"
    else
        xcode-select --install
        sudo xcodebuild -license accept
    fi
}

install_homebrew() {
    info "💿 Installing Homebrew…"
    export HOMEBREW_CASK_OPTS="--appdir=/Applications"
    if hash brew &>/dev/null; then
        warning "Homebrew already installed"
    else
        sudo --validate
        NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    # A fresh install is not on PATH yet in this shell, and the rest of the
    # installers call brew directly
    if ! hash brew &>/dev/null; then
        local brew_bin
        for brew_bin in /opt/homebrew/bin/brew /usr/local/bin/brew; do
            if [ -x "$brew_bin" ]; then
                eval "$("$brew_bin" shellenv)"
                break
            fi
        done
    fi

    if ! hash brew &>/dev/null; then
        error "Homebrew is not available after installation; aborting."
        exit 1
    fi
}

install_macos_prerequisites() {
    install_xcode
    install_homebrew
}

# Only run if script is executed, not sourced
if [ "$(basename "$0")" = "$(basename "${BASH_SOURCE[0]}")" ]; then
    install_xcode
    install_homebrew
fi
