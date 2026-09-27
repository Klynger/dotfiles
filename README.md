# dotfiles

This repository contains my dotfiles, which configure my development environment on two machines: a MacBook and a CachyOS + Hyprland desktop.

## Layout

Configuration that applies to both machines lives at the repository root (`nvim/`, `tmux/`, `yazi/`, `vim/`, `ai/`). OS-specific configuration lives in a directory per OS: `macos/` and `linux/` (the imported hyprland-desktop-config, with its own docs in `linux/AGENTS.md`). Each OS directory is dead code on the other machine by design.

`./install.sh` detects the OS and runs only what belongs there: shared brew-formula installers everywhere (CLI tools come from Homebrew on macOS and linuxbrew on Linux), casks and prerequisites only on macOS, and the desktop layer via pacman and the AUR on Linux. The Linux side targets Arch or Arch-based distros only, and the installer refuses to run on anything without pacman. Symlinks follow the same split: `scripts/symlinks.sh` always applies `symlinks/general.conf` and adds the OS-specific conf when one exists.

On a brand-new Mac, `git` is only a stub until the Command Line Tools exist, and `install.sh` is what installs them. Either let the stub prompt you (run `git clone`, accept the dialog, clone again) or fetch a tarball first and let the script handle the tools unattended:

```bash
mkdir -p ~/dev && curl -fsSL https://github.com/Klynger/dotfiles/archive/refs/heads/main.tar.gz | tar xz -C ~/dev && mv ~/dev/dotfiles-main ~/dev/dotfiles && cd ~/dev/dotfiles && ./install.sh --yes
```

Afterwards replace the tarball with a real checkout (`rm -rf ~/dev/dotfiles && git clone git@github.com:Klynger/dotfiles.git ~/dev/dotfiles`); the symlinks point at the same path. This flow was verified on a vanilla macOS VM in September 2026.

On a brand-new Arch (or Arch-based) machine, the same tarball command works as-is: `curl` ships with the base system and the installer pulls everything else, including `git`, the full Hyprland desktop from pacman and the AUR, linuxbrew for the CLI tools, and a seeded matugen theme so the first login is not half-broken. Verified end to end on a vanilla Arch VM in September 2026. Three things to know:

- The AUR bootstrap installs `paru` from the distro repos when available (CachyOS ships it); on vanilla Arch it builds paru from source, which needs roughly 8 GB of RAM or swap for the final link.
- sddm is installed but not enabled on purpose; finish with `sudo systemctl enable sddm` and a reboot.
- The theme is seeded from a fallback color until `~/Pictures/Wallpapers/current` has images; run `change-wallpaper` after adding some.

```bash
# Full setup, answering each prompt
./install.sh

# Unattended: take the default for every prompt, or pre-answer single ones
./install.sh --yes
DOTFILES_INSTALL_APPS=n DOTFILES_INSTALL_FONTS=n ./install.sh --yes

# Symlinks only
./scripts/symlinks.sh --create
./scripts/symlinks.sh --delete

# Sanity-check both OS code paths against a throwaway $HOME
./scripts/tests/smoke_test.sh
```

## Requirements

Each component that depends on external tools lists them in a `requirements.conf` next to its config (for example [nvim/requirements.conf](nvim/requirements.conf)), one tool per line with an optional minimum version and the command that installs it.

`install.sh` runs `scripts/check_requirements.sh` before creating any symlink and stops when something is missing or too old. To check by hand:

```bash
./scripts/check_requirements.sh
```

Inside Neovim the same file backs `:checkhealth core`, and a warning shows on startup when a requirement is not met.
