#!/bin/bash

# Get the absolute path of the directory where the script is loaded
SCRIPT_DIR="$(cd "$(dirname "$BASH_SOURCE[0]}")" && pwd)"

. $SCRIPT_DIR/utils.sh
. $SCRIPT_DIR/install_fzf.sh

install_mpv() {
    info "Installing mpv…"

    OS=$(detect_os)
    case $OS in
    "macos")
        if hash mpv &>/dev/null; then
            warning "mpv already installed"
        else
            brew install mpv
        fi
        ;;
    "ubuntu")
        if hash mpv &>/dev/null; then
            warning "mpv already installed"
        else
            sudo apt-get install mpv
        fi
        ;;
    *)
        error "Unsupported OS for mpv installation: $OS"
        exit 1
        ;;
    esac
}

install_yazi() {
    info "💿 Installing yazi…"

    OS=$(detect_os)
    case $OS in
    "macos")
        if hash yazi &>/dev/null; then
            warning "yazi already installed"
        else
            install_fzf
            brew install yazi ffmpeg sevenzip jq poppler fd ripgrep zoxide resvg imagemagick font-symbols-only-nerd-font
        fi
        ;;
    "ubuntu")
        if hash yazi &>/dev/null; then
            warning "yazi already installed"
        else
            sudo apt install ffmpeg 7zip jq poppler-utils fd-find ripgrep fzf zoxide imagemagick
            curl --proto '=https' -tlsv1.2 -sSf https://sh.rustup.rs | sh
            rustup update
            git clone https://github.com/sxyazi/yazi.git
            cd yazi
            cargo build --locked
            cd ..
            rm -rf yazi
        fi
        ;;
    *)
        error "Unsupported OS for yazi installation: $OS"
        exit 1
        ;;
    esac
}

# Only run if script is executed, not sourced
if [ "$(basename "$0")" = "$(basename "${BASH_SOURCE[0]}")" ]; then
    install_fzf
    install_mpv
    install_yazi
fi
