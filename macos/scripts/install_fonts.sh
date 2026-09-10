#!/bin/bash

install_fonts() {
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

# Only run if script is executed, not sourced
if [ "$(basename "$0")" = "$(basename "${BASH_SOURCE[0]}")" ]; then
    install_fonts
fi

