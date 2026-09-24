# Shared by every machine; nothing here is generated. Machine-only lines go
# in ~/.zshrc.local, the prompt config in ~/.p10k.zsh (p10k configure), both
# untracked.

# Powerlevel10k instant prompt. Keep it near the top; quiet mode tolerates
# the fastfetch output at the end of this file.
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Homebrew (macOS) or linuxbrew provides the CLI tools and the zsh plugins
if ! command -v brew &>/dev/null; then
  for brew_bin in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
    [[ -x "$brew_bin" ]] && eval "$("$brew_bin" shellenv)" && break
  done
  unset brew_bin
fi

# Oh My Zsh for its plugin framework; the theme and the extra plugins come
# from brew instead of ~/.oh-my-zsh/custom (see scripts/install_zsh.sh)
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""
plugins=(git fzf)
source "$ZSH/oh-my-zsh.sh"

BREW_PREFIX="$(brew --prefix)"
source "$BREW_PREFIX/share/powerlevel10k/powerlevel10k.zsh-theme"
source "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
source "$BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# History
HISTFILE="$HOME/.zsh_history"
HISTSIZE=1000
SAVEHIST=1000
setopt share_history hist_expire_dups_first hist_ignore_dups hist_verify
bindkey '^P' history-search-backward
bindkey '^N' history-search-forward
bindkey '^Y' end-of-line

# Environment
export EDITOR='nvim'
export VISUAL="$EDITOR"
export PATH="$PATH:$HOME/.local/bin"
export TURBO_TELEMETRY_DISABLED=1

# Fuzzy-pick files and open them in nvim
alias fzfn='f() { local files; files=$(fzf -m --preview="bat --color=always {}") && [ -n "$files" ] && nvim $files; }; f'

# Open yazi and cd into the directory it was left in
function y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  yazi "$@" --cwd-file="$tmp"
  IFS= read -r -d '' cwd <"$tmp"
  [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
  rm -f -- "$tmp"
}

[[ ! -f ~/.zshrc.local ]] || source ~/.zshrc.local

# Linux desktop only; the command check keeps macOS quiet
if [[ -o interactive ]] && command -v fastfetch &>/dev/null; then
  fastfetch
fi
