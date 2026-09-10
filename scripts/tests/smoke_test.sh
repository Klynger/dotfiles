#!/bin/bash

# Runs symlink create + delete for each OS code path against a throwaway
# $HOME and fails when a link is missing, dangling, or left behind.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

. "$REPO_DIR/scripts/utils.sh"

failures=0

run_os() {
    local os="$1"
    local fake_home
    fake_home="$(mktemp -d)"

    info "[$os] creating symlinks in $fake_home"
    (cd "$REPO_DIR" && HOME="$fake_home" DOTFILES_OS="$os" ./scripts/symlinks.sh --create >/dev/null)

    HOME="$fake_home" expected_targets "$os" | while IFS= read -r target; do
        if [ ! -L "$target" ]; then
            error "[$os] missing symlink: $target"
            exit 1
        fi
    done || failures=$((failures + 1))

    local dangling
    dangling="$(find "$fake_home" -xtype l)"
    if [ -n "$dangling" ]; then
        error "[$os] dangling symlinks:"
        printf "%s\n" "$dangling"
        failures=$((failures + 1))
    fi

    (cd "$REPO_DIR" && HOME="$fake_home" DOTFILES_OS="$os" ./scripts/symlinks.sh --delete >/dev/null)

    local leftover
    leftover="$(find "$fake_home" -type l)"
    if [ -n "$leftover" ]; then
        error "[$os] links left behind after delete:"
        printf "%s\n" "$leftover"
        failures=$((failures + 1))
    fi

    rm -rf "$fake_home"
}

# Prints the expanded symlink targets for one OS, one per line
expected_targets() {
    local os="$1"
    local confs=("$REPO_DIR/symlinks/general.conf")
    if [ -f "$REPO_DIR/symlinks/$os.conf" ]; then
        confs+=("$REPO_DIR/symlinks/$os.conf")
    fi

    local source target
    while IFS=: read -r source target || [ -n "$source" ]; do
        if [[ -z "$source" || -z "$target" || "$source" == \#* ]]; then
            continue
        fi
        eval echo "$target"
    done < <(cat "${confs[@]}")
}

for os in linux macos; do
    run_os "$os"
done

if [ "$failures" -gt 0 ]; then
    error "Smoke test failed"
    exit 1
fi

success "Smoke test passed for linux and macos"
