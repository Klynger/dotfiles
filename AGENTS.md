# AGENTS.md - Dotfiles Repository

## Overview

This is a **macOS dotfiles** repository for configuring a development environment. It contains
configuration for Neovim, tmux, kitty, wezterm, yazi, vim, and VS Code, plus shell scripts
that automate installation and symlink management. The primary platform is **macOS** with
**Homebrew** as the package manager.

## Repository Structure

```
.
├── install.sh              # Main entry point - orchestrates full setup
├── symlinks.conf           # Declarative symlink mappings (source:target)
├── scripts/                # Bash install/setup scripts
│   ├── utils.sh            # Shared logging helpers (info, success, error, warning)
│   ├── symlinks.sh         # Creates/deletes symlinks from symlinks.conf
│   ├── prerequisites/      # Xcode CLI tools + Homebrew
│   └── install_*.sh        # Per-tool installers (nvim, tmux, fzf, kitty, etc.)
├── nvim/                   # Neovim configuration (Lua)
│   ├── init.lua            # Entry point - loads core + lazy.nvim plugins
│   ├── .stylua.toml        # Lua formatter config
│   ├── .luarc.json         # Lua language server config
│   └── lua/
│       ├── core/           # options.lua, keymaps.lua
│       └── plugins/        # One file per plugin (lazy.nvim spec format)
│           └── lsp/        # LSP sub-configs (go_ls, lua_ls, typescript, etc.)
├── tmux/                   # tmux config (.tmux.conf)
├── kitty/                  # Kitty terminal config
├── wezterm/                # WezTerm config (Lua)
├── yazi/                   # Yazi file manager config (TOML)
├── vim/                    # Legacy .vimrc
├── vscode/                 # VS Code settings + keybindings
└── rectangle/              # Rectangle window manager config
```

## Build / Install / Test Commands

There is no traditional build system, test suite, or CI pipeline. This is a config-only repo.

### Full installation
```bash
./install.sh
```
This interactively prompts to install apps, overwrite dotfiles, and install fonts.

### Symlinks only
```bash
# Create symlinks defined in symlinks.conf
./scripts/symlinks.sh --create

# Delete symlinks (and backing files if --include-files)
./scripts/symlinks.sh --delete
./scripts/symlinks.sh --delete --include-files
```

### Individual tool installers
Each script in `scripts/` can be run standalone:
```bash
./scripts/install_nvim.sh
./scripts/install_tmux.sh
./scripts/install_fzf.sh
# etc.
```

### Lua formatting (Neovim config)
```bash
# Format all Lua files using the .stylua.toml config
stylua nvim/
```

### Shell formatting (used by Neovim's conform.nvim)
```bash
shfmt -w scripts/
```

### No tests
There is no test framework. Verify changes by sourcing configs or restarting the relevant tool.

## Code Style Guidelines

### Bash Scripts (`scripts/`)

- **Shebang**: Always start with `#!/bin/bash`
- **Quoting**: Double-quote variable expansions (`"$variable"`), especially paths
- **Functions**: Use `snake_case` for function names (e.g., `install_nvim`, `create_symlinks`)
- **Variables**: `snake_case` for locals, `UPPER_CASE` for constants/env vars (e.g., `SCRIPT_DIR`, `CONFIG_FILE`)
- **Sourcing utils**: Source `utils.sh` at the top via `. $SCRIPT_DIR/utils.sh`
- **Logging**: Use `info`, `success`, `warning`, `error` helpers from `utils.sh` - never raw `echo` for status
- **SCRIPT_DIR pattern**: Every script resolves its own directory:
  ```bash
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  ```
- **Idempotency**: Check if a tool is already installed before installing (use `hash cmd &>/dev/null` or `which cmd &>/dev/null`)
- **Source guard**: Scripts that can be sourced should guard direct execution:
  ```bash
  if [ "$(basename "$0")" = "$(basename "${BASH_SOURCE[0]}")" ]; then
      main_function
  fi
  ```
- **Indentation**: 4 spaces
- **Formatter**: `shfmt`

### Lua - Neovim Config (`nvim/lua/`)

- **Formatter**: StyLua (config in `nvim/.stylua.toml`)
  - Column width: 120
  - Indent: 2 spaces
  - Quote style: single quotes preferred (`AutoPreferSingle`)
  - Line endings: Unix (LF)
  - Call parentheses: Always
- **Plugin specs**: Each plugin gets its own file in `nvim/lua/plugins/` returning a lazy.nvim table
- **Module pattern**: Sub-modules (e.g., LSP configs) use the `local M = {} ... return M` pattern
- **Requires**: Use `require('module.path')` with single quotes and dot-separated paths
- **Naming**: `snake_case` for variables and functions; filenames use `kebab-case` (e.g., `auto-session.lua`)
- **Type annotations**: Use `---@param` and `---@type` LuaCATS annotations where helpful
- **Keymaps**: Use `vim.keymap.set()` with a `desc` field for discoverability (which-key)
- **Keymap descriptions**: Follow `[L]etter [W]ord` bracket notation (e.g., `'[S]earch [F]iles'`)
- **Error handling**: Use `pcall()` for operations that may fail (e.g., loading optional extensions)
- **Comments**: Prefix actionable notes with `TODO:`, `WARN:`, `NOTE:` (todo-comments.nvim highlights these)
- **Global vim**: `vim` is a recognized global (configured in `.luarc.json`)

### Lua - WezTerm Config (`wezterm/`)

- Double quotes for strings (WezTerm convention)
- Indentation: 2 spaces (follows StyLua defaults)
- Returns a config table built with `wezterm.config_builder()`

### TOML Files (`yazi/`, `nvim/.stylua.toml`)

- Indentation: 2 spaces (tabs in alignment columns are acceptable in yazi config)
- Use schema references where available (`$schema` key)

### Kitty Config

- Uses `vim:fileencoding=utf-8:foldmethod=marker` modeline
- Sections delimited by `#: Section Name {{{` / `#: }}}` fold markers

### General

- **Line endings**: Unix (LF) everywhere
- **Trailing newline**: Files end with a single trailing newline
- **No secrets**: Do not commit credentials, tokens, or API keys
- **Symlinks**: New config directories that should be linked must be added to `symlinks.conf`

## Key Technical Details

- **Package manager**: Homebrew (macOS)
- **Shell**: Zsh (with Powerlevel10k, autosuggestions, syntax highlighting)
- **Editor**: Neovim with lazy.nvim plugin manager
- **LSP servers**: TypeScript (typescript-tools.nvim), Go (gopls), Lua (lua_ls), Tailwind CSS, Svelte, ESLint, SQL, Bash
- **Formatters**: StyLua (Lua), shfmt (Bash), prettier + eslint_d (JS/TS), gofmt (Go), sqlfluff (SQL)
- **Color theme**: Tokyo Night (Neovim), Catppuccin (tmux, kitty)
- **Terminal**: WezTerm or Kitty
- **File manager**: Yazi
- **Tmux prefix**: `C-s` (rebound from default `C-b`)
- **Neovim leader**: Space

## Gotchas

- `tmux/plugins/` is gitignored (managed by TPM at runtime)
- `nvim/spell/` is gitignored
- The `install.sh` entry point sources all scripts (does not execute them as subprocesses), so function names must not collide
- Some install scripts have a minor quoting bug in `SCRIPT_DIR` (`"$BASH_SOURCE[0]}"` missing opening brace) - this works when sourced from `install.sh` but may fail if run standalone
