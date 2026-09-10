# dotfiles

This repository contains my dotfiles, which configure my development environment on two machines: a MacBook and a CachyOS + Hyprland desktop.

## Layout

Configuration that applies to both machines lives at the repository root (`nvim/`, `tmux/`, `yazi/`, `vim/`, `ai/`). OS-specific configuration lives in a directory per OS: `macos/` and `linux/` (the imported hyprland-desktop-config, with its own docs in `linux/AGENTS.md`). Each OS directory is dead code on the other machine by design.

`./install.sh` detects the OS and runs only what belongs there: shared brew-formula installers everywhere (CLI tools come from Homebrew on macOS and linuxbrew on Linux), casks and prerequisites only on macOS, desktop packages left to pacman on Linux. Symlinks follow the same split: `scripts/symlinks.sh` always applies `symlinks/general.conf` and adds the OS-specific conf when one exists.

```bash
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
