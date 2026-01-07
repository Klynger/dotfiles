#!/bin/bash

install_fonts_macos() {
    info "Installing fonts…"

   if [[ -z `find ~/Library/Fonts -type f -name "HackNerd*"` ]]; then 
        echo "💿 [Fonts] Installing HackNerd…"
        brew install font-hack-nerd-font && echo "✅ [Fonts] HackNerd installed!" || exit 1
    else 
        echo "⏭️ [Fonts] HackNerd already installed!"
    fi

    # https://github.com/githubnext/monaspace
    if [[ -z `find ~/Library/Fonts -type f -name "Monaspace*"` ]]; then
        echo "💿 [Fonts] Installing Monaspace…"
        brew install font-monaspace && echo "✅ [Fonts] Monaspace installed!" || exit 1
    else 
        echo "⏭️ [Fonts] Monaspace already installed!"
    fi

    # https://github.com/ryanoasis/nerd-fonts
    if [[ -z `find ~/Library/Fonts -type f -name "MesloLG*` ]]; then
        echo "💿 [Fonts] Installing MesloLG…"
        brew install --cask font-meslo-lg-nerd-font && echo "✅ [Fonts] MesloLG installed!" || exit 1
    else 
        echo "⏭️ [Fonts] MesloLG already installed!"
    fi

    if [[ -z `find ~/Library/Fonts -type f -name "FiraCode*"` ]]; then
        echo "💿 [Fonts] Installing FiraCode…"
        brew install --cask font-fira-code-nerd-font && echo "✅ [Fonts] FiraCode installed!" || exit 1
    else 
        echo "⏭️ [Fonts] FiraCode already installed!"
    fi
}

install_fonts_ubuntu() {
    info "Installing fonts on Ubuntu…"

    FONT_DIR="$HOME/.local/share/fonts"
    mkdir -p "$FONT_DIR"

        # Install Hack Nerd Font
    if [[ ! -f "$FONT_DIR/Hack Regular Nerd Font Complete.ttf" ]]; then
        echo "💿 [Fonts] Installing HackNerd…"
        wget -O /tmp/Hack.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/Hack.zip
        unzip /tmp/Hack.zip -d "$FONT_DIR"
        fc-cache -fv
        echo "✅ [Fonts] HackNerd installed!"
    else
        echo "⏭️ [Fonts] HackNerd already installed!"
    fi
}

install_fonts() {
    OS=$(detect_os)
    case $OS in
        "macos")
            install_fonts_macos
            ;;
        "ubuntu")
            install_fonts_ubuntu
            ;;
        *)
            error "Unsupported OS for font installation: $OS"
            exit 1
            ;;
    esac
}

# Only run if script is executed, not sourced
if [ "$(basename "$0")" = "$(basename "${BASH_SOURCE[0]}")" ]; then
    install_fonts
fi

