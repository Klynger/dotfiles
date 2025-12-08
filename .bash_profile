# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

alias fzfn='f() { local files; files=$(fzf -m --preview="bat --color=always {}") && [ -n "$files" ] && nvim $files; }; f'

EDITOR='nvim'
