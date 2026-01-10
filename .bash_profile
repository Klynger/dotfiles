[[ -f ~/.bashrc ]] && . ~/.bashrc

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

alias fzfn='f() { local files; files=$(fzf -m --preview="bat --color=always {}") && [ -n "$files" ] && nvim $files; }; f'

export EDITOR='nvim'
export VISUAL=$EDITOR

function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd <"$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}
