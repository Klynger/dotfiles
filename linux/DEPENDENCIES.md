# Dependencies

External packages required by this configuration.

## Core

| Package | Purpose |
|---------|---------|
| hyprland | Window manager |
| hyprlock | Lock screen |
| sddm | Display/login manager |
| hypridle | Idle/sleep daemon |
| hyprshot | Screenshots |
| quickshell | Desktop shell: bar, notifications, launcher, controls, dashboard, lock |
| swww | Wallpaper daemon |
| uwsm | Systemd user session manager |

## Terminal & Apps

| Package | Purpose |
|---------|---------|
| wezterm | Terminal emulator |
| thunar | File manager (GUI) |
| gvfs | Trash, mounts and MTP for thunar |
| google-chrome | Browser |
| btop | System monitor |
| gnome-calculator | Calculator |

## Media & Audio

| Package | Purpose |
|---------|---------|
| playerctl | Media player control (MPRIS) |
| wireplumber (wpctl) | Audio control |
| pavucontrol | Volume control GUI |

## System Utilities

| Package | Purpose |
|---------|---------|
| brightnessctl | Screen brightness |
| imagemagick (magick) | sddm background seeding (seed-theme.sh) |
| notify-send (libnotify) | Desktop notifications |
| curl | HTTP requests (webapp icon downloads) |
| gum | Interactive shell prompts (webapp-install) |
| fzf (via linuxbrew) | Keybindings cheatsheet search (show-keybindings) |
| gsettings (glib2) | GNOME/GTK settings |
| xdg-utils | xdg-settings, xdg-terminal-exec |
| gtk-launch (gtk3) | Launch .desktop apps |
| gtk4 | GTK4 runtime for libadwaita apps |
| update-desktop-database (desktop-file-utils) | .desktop file cache |

## Network

| Package | Purpose |
|---------|---------|
| impala | TUI WiFi configuration |
| bluetui | TUI Bluetooth manager |
| rfkill (util-linux) | WiFi/Bluetooth toggle |

## Fonts

| Package | Purpose |
|---------|---------|
| adwaita-fonts | Adwaita Mono, the desktop UI font (sddm, hyprlock, plain-text surfaces) |
| AdwaitaMono Nerd Font (`getnf -i AdwaitaMono`) | The same font patched with glyph icons, for the shell, GTK and wezterm |
| noto-fonts | General text fallback |

## Theming

| Package | Purpose |
|---------|---------|
| bibata-modern-ice-cursor | Cursor theme |

## Optional (detected dynamically)

| Package | Purpose |
|---------|---------|
| firefox / zen-browser / librewolf / mullvad-browser | Alternative browsers |
| steam | Game launcher |
