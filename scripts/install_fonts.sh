#!/bin/bash

install_fonts() {
    info "Installing fonts…"

   if [[ -z `find ~/Library/Fonts -type f -name "HackNerd*"` ]]; then 
        echo "I💿 [Fonts] Installing HackNerd…"
        brew install font-hack-nerd-font && echo "✅ [Fonts] HackNerd installed!" || exit 1
    else 
        echo "⏭️  [Fonts] HackNerd already installed!"
    fi

    # https://github.com/githubnext/monaspace
    if [[ -z `find ~/Library/Fonts -type f -name "Monaspace*"` ]]; then
        echo "💿 [Fonts] Installing Monaspace…"
        brew install font-monaspace && echo "✅ [Fonts] Monaspace installed!" || exit 1
    else 
        echo "⏭️  [Fonts] Monaspace already installed!"
    fi
}
