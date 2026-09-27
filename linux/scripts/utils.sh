#!/bin/bash

# Colors only when stdout is a terminal that tput knows; unattended runs
# (piped output, no TERM) get plain text instead of tput errors, which
# matters extra here: the copy scripts run under set -e and a failing tput
# in this file kills them at source time
if [ -t 1 ] && [ -n "$TERM" ] && tput sgr0 &>/dev/null; then
    default_color=$(tput sgr0)
    red="$(tput setaf 1)"
    yellow="$(tput setaf 3)"
    green="$(tput setaf 2)"
    blue="$(tput setaf 4)"
else
    default_color=""
    red=""
    yellow=""
    green=""
    blue=""
fi

info() {
    printf "%s==> %s%s\n" "$blue" "$1" "$default_color"
}

success() {
    printf "%s==> %s%s\n" "$green" "$1" "$default_color"
}

error() {
    printf "%s==> %s%s\n" "$red" "$1" "$default_color"
}

warning() {
    printf "%s==> %s%s\n" "$yellow" "$1" "$default_color"
}
