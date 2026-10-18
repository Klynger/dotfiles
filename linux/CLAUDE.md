# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

> A comprehensive developer reference already exists in `AGENTS.md` — read it for full detail on code style, naming conventions, and important caveats.

---

## What This Repo Is

A personal Hyprland Wayland desktop dotfiles repository. No compiled code, no package manager, no test runner. Languages: Bash, Hyprland config DSL (`.conf`), Lua, QML (quickshell), CSS, TOML.

---

## Installation

```bash
# Symlink all configs (idempotent, safe to re-run) — shared machinery at the
# repo root, reading symlinks/general.conf + symlinks/linux.conf
(cd .. && ./scripts/symlinks.sh --create)

# Copy machine-specific files once per machine (monitors.lua, autostart.lua)
./scripts/copy-base-files.sh

# Symlink bin/ scripts to $XDG_BIN_HOME (~/.local/bin)
./scripts/install-binaries.sh

# Root-level copies (SDDM theme, etc.) — requires sudo
sudo ./scripts/copies-root.sh --create
```

---

## Linting / Validation

No automated tests. Validate shell scripts manually:

```bash
shellcheck scripts/*.sh
shellcheck bin/*

shfmt -i 4 -w scripts/*.sh
shfmt -i 4 -w bin/*
```

---

## Architecture

### How configs are deployed

`symlinks/linux.conf` at the repo root declares source→target pairs (shell-expandable paths using `$HOME`/`$(pwd)`) that the root `scripts/symlinks.sh --create` turns into symlinks in `~/.config/`. `basefiles.conf` declares files that must be **copied** (not symlinked) because they are machine-specific.

### Machine-specific files (gitignored)

`hypr/monitors.lua` and `hypr/autostart.lua` are gitignored. Edit templates in `hypr_copies/` instead. Never commit the actual files.

### Hyprland config structure

`hypr/hyprland.lua` (Lua config, Hyprland ≥ 0.55) `require()`s all sub-configs:
- `programs.lua` — returns a table with `terminal`, `browser`, `fileManager`
- `bindings.lua` — keybindings via `hl.bind()` (Super+hjkl, workspaces 1–10, media/volume/brightness)
- `looknfeel.lua` — gaps, borders, animations, blur, shadows via `hl.config()`/`hl.animation()`
- `windows.lua` — `hl.window_rule()` / `hl.layer_rule()` per app
- `envs.lua` / `inputs.lua` — `hl.env()` calls and input settings
- `monitors.lua` / `autostart.lua` — machine-specific, gitignored; templates in `hypr_copies/`
- `hypridle.conf` / `hyprlock.conf` — idle/lock screen (separate apps, still hyprlang)

Lua API stubs for the LSP are wired via `.luarc.json` (stubs live in `/usr/share/hypr/stubs`).

### Theming

The theme is static Tokyo Night. The shell's tokens live in `quickshell/components/Theme.qml`; GTK palettes in `gtk-3.0/colors-dark.css`/`colors-light.css` (copied over the gitignored `colors.css` by `toggle-theme-mode`); hyprlock and sddm colors are inline in their configs. Light/dark is driven by the GTK color-scheme gsetting, flipped by `toggle-theme-mode` (bound to the bar's switch); wezterm and nvim follow it on their own.

### bin/ scripts

`bin/` contains user-facing helpers (no extension, executable, kebab-case):
- `launch-or-focus` — single-instance launcher using `hyprctl clients -j | jq`
- `launch-webapp` / `launch-or-focus-webapp` — web apps as first-class desktop apps
- `webapp-install` — interactive .desktop file creator (uses `gum`)
- `launch-browser` — detects default browser and maps `--private` to the correct flag
- `change-wallpaper` — random wallpaper from `~/Pictures/Wallpapers/current` via `awww`
- `toggle-theme-mode` — toggles light/dark via `gsettings`

All scripts in `bin/` are auto-discovered by `install-binaries.sh` — no registration needed.

### Script conventions

- Use `scripts/utils.sh` helpers (`info`, `success`, `warning`, `error`) — never raw `echo`
- Source with POSIX dot: `. "$SCRIPT_DIR/utils.sh"`
- `set -euo pipefail` in new scripts
- Always double-quote variables; use `mapfile -t` for arrays
- `symlinks.sh` uses `eval` to expand paths — only use `$HOME` and `$(pwd)` in conf files

---

## Key Caveats

- Do not hardcode usernames or absolute home paths — use `$HOME` or `~`
- `symlinks/linux.conf` must use eval-expandable paths only (`$(pwd)`, `$HOME`)
- New `bin/` scripts must be `chmod +x`
- When adding a new config directory, add its symlink entry to `symlinks/linux.conf` at the repo root
- When adding or removing a dependency, update `DEPENDENCIES.md` to keep it in sync
- When adding font dependencies, update the Fonts section in `DEPENDENCIES.md`. Use `getnf -i <FontName>` for Nerd Fonts, or the system package manager for standard fonts (e.g., `noto-fonts`)
