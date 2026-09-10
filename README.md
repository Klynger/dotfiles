# dotfiles

This repository contains my dotfiles, which configure my development environment.

## Requirements

Each component that depends on external tools lists them in a `requirements.conf` next to its config (for example [nvim/requirements.conf](nvim/requirements.conf)), one tool per line with an optional minimum version and the command that installs it.

`install.sh` runs `scripts/check_requirements.sh` before creating any symlink and stops when something is missing or too old. To check by hand:

```bash
./scripts/check_requirements.sh
```

Inside Neovim the same file backs `:checkhealth core`, and a warning shows on startup when a requirement is not met.
