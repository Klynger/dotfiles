
#!/bin/bash

# Get the absolute path of the directory where the script is loaded
SCRIPT_DIR="$(cd "$(dirname "$BASH_SOURCE[0]}")" && pwd)"

. $SCRIPT_DIR/utils.sh

install_wezterm() {
    info "💿 Installing Wezterm terminal emulator…"

    if hash wezterm &>/dev/null; then
        warning "Wezterm already installed"
    else
        brew install --cask wezterm
    fi
}

# Only run if script is executed, not sourced
if [ "$(basename "$0")" = "$(basename "${BASH_SOURCE[0]}")" ]; then
   install_wezterm 
fi
