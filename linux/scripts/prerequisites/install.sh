#!/bin/bash

# Fresh Arch (or Arch-based) prerequisites: the desktop packages from
# linux/DEPENDENCIES.md via pacman and an AUR helper, plus linuxbrew for the
# shared CLI installers. Failures are reported, not fatal, mirroring the
# brew installers; the package lists are validated by the VM install test.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. "$SCRIPT_DIR/../utils.sh"

# Official repos (extra unless noted); base-devel, git and curl also cover
# the paru and linuxbrew bootstraps
PACMAN_PACKAGES=(
    base-devel git curl
    hyprland hypridle hyprlock uwsm
    waybar rofi-wayland swaync swww sddm
    wezterm nautilus btop gnome-calendar gnome-calculator
    playerctl wireplumber pavucontrol
    brightnessctl imagemagick libnotify gum glib2 xdg-utils
    gtk3 gtk4 gtk4-layer-shell desktop-file-utils python-gobject
    noto-fonts ttf-nerd-fonts-symbols
    mpv papers adw-gtk-theme impala bluetui
)

AUR_PACKAGES=(
    wlogout
    matugen-bin
    hyprshot
    bibata-cursor-theme-bin
    google-chrome
    getnf
    xdg-terminal-exec
)

install_pacman_packages() {
    info "💿 Syncing pacman and installing the desktop packages…"
    sudo pacman -Syu --noconfirm || error "pacman -Syu failed, continuing"

    local pkg
    for pkg in "${PACMAN_PACKAGES[@]}"; do
        if pacman -Qi "$pkg" &>/dev/null; then
            warning "$pkg already installed"
        elif sudo pacman -S --needed --noconfirm "$pkg"; then
            success "$pkg installed"
        else
            error "$pkg failed to install, continuing"
        fi
    done
}

# Prints the available AUR helper, bootstrapping paru when there is none
install_aur_helper() {
    if hash paru &>/dev/null; then
        printf "paru"
        return
    fi
    if hash yay &>/dev/null; then
        printf "yay"
        return
    fi

    # Arch-based distros like CachyOS ship paru in their own repos
    if sudo pacman -S --needed --noconfirm paru &>/dev/null; then
        printf "paru"
        return
    fi

    # Built from source on purpose: the prebuilt paru-bin lags pacman's
    # libalpm soname bumps and then fails to even start on a fresh system
    info "💿 Building paru from the AUR…" >&2
    local build_dir
    build_dir="$(mktemp -d)"
    if git clone -q https://aur.archlinux.org/paru.git "$build_dir/paru" &&
        (cd "$build_dir/paru" && makepkg -si --noconfirm) >&2; then
        rm -rf "$build_dir"
        printf "paru"
    else
        rm -rf "$build_dir"
        error "paru failed to build; AUR packages will be skipped" >&2
    fi
}

install_aur_packages() {
    local helper
    helper="$(install_aur_helper)"
    if [ -z "$helper" ]; then
        error "No AUR helper available; skipped: ${AUR_PACKAGES[*]}"
        return
    fi

    info "💿 Installing the AUR packages with $helper…"
    local pkg
    for pkg in "${AUR_PACKAGES[@]}"; do
        if pacman -Qi "$pkg" &>/dev/null; then
            warning "$pkg already installed"
        elif "$helper" -S --needed --noconfirm "$pkg"; then
            success "$pkg installed"
        else
            error "$pkg failed to install, continuing"
        fi
    done
}

install_linuxbrew() {
    info "💿 Installing Homebrew (linuxbrew)…"
    if hash brew &>/dev/null; then
        warning "Homebrew already installed"
        return
    fi

    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # A fresh install is not on PATH yet in this shell, and the rest of the
    # installers call brew directly
    local brew_bin
    for brew_bin in /home/linuxbrew/.linuxbrew/bin/brew "$HOME/.linuxbrew/bin/brew"; do
        if [ -x "$brew_bin" ]; then
            eval "$("$brew_bin" shellenv)"
            break
        fi
    done

    if ! hash brew &>/dev/null; then
        error "Homebrew is not available after installation; aborting."
        exit 1
    fi
}

install_linux_desktop_packages() {
    sudo --validate
    install_pacman_packages
    install_aur_packages
}

# Only run if script is executed, not sourced. Compared as paths, not
# basenames: the top-level install.sh shares this file's name
if [ "$0" = "${BASH_SOURCE[0]}" ]; then
    install_linux_desktop_packages
    install_linuxbrew
fi
