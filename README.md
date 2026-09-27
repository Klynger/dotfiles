# dotfiles

This repository contains my dotfiles, which configure my development environment on two machines: a MacBook and a CachyOS + Hyprland desktop.

## Layout

Configuration that applies to both machines lives at the repository root (`nvim/`, `tmux/`, `yazi/`, `vim/`, `ai/`). OS-specific configuration lives in a directory per OS: `macos/` and `linux/` (the imported hyprland-desktop-config, with its own docs in `linux/AGENTS.md`). Each OS directory is dead code on the other machine by design.

`./install.sh` detects the OS and runs only what belongs there: shared brew-formula installers everywhere (CLI tools come from Homebrew on macOS and linuxbrew on Linux), casks and prerequisites only on macOS, desktop packages left to pacman on Linux. Symlinks follow the same split: `scripts/symlinks.sh` always applies `symlinks/general.conf` and adds the OS-specific conf when one exists.

On a brand-new Mac, `git` is only a stub until the Command Line Tools exist, and `install.sh` is what installs them. Either let the stub prompt you (run `git clone`, accept the dialog, clone again) or fetch a tarball first and let the script handle the tools unattended:

```bash
mkdir -p ~/dev && curl -fsSL https://github.com/Klynger/dotfiles/archive/refs/heads/main.tar.gz | tar xz -C ~/dev && mv ~/dev/dotfiles-main ~/dev/dotfiles && cd ~/dev/dotfiles && ./install.sh --yes
```

Afterwards replace the tarball with a real checkout (`rm -rf ~/dev/dotfiles && git clone git@github.com:Klynger/dotfiles.git ~/dev/dotfiles`); the symlinks point at the same path. This flow was verified on a vanilla macOS VM in September 2026.

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
