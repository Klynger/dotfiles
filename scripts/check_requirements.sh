#!/bin/bash

# Checks every <component>/requirements.conf in the repo. Each line is
#   tool | minimum version (empty = presence only) | how to install
# The version is read from `<tool> --version` and the first x.y[.z] in the
# output is compared with the minimum.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$SCRIPT_DIR/.."

. "$SCRIPT_DIR/utils.sh"

trim() {
    local value="$1"
    value="${value#"${value%%[![:space:]]*}"}"
    value="${value%"${value##*[![:space:]]}"}"
    printf "%s" "$value"
}

installed_version() {
    "$1" --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1
}

# Returns 0 when $1 >= $2
version_at_least() {
    [ "$(printf "%s\n%s\n" "$2" "$1" | sort -V | head -1)" = "$2" ]
}

check_requirements_file() {
    local config_file="$1"
    local component
    component="$(basename "$(dirname "$config_file")")"
    local failures=0

    info "Checking requirements for $component…"

    while IFS='|' read -r tool min_version install_hint || [ -n "$tool" ]; do
        tool="$(trim "$tool")"
        min_version="$(trim "$min_version")"
        install_hint="$(trim "$install_hint")"

        if [[ -z "$tool" || "$tool" == \#* ]]; then
            continue
        fi

        if ! command -v "$tool" &>/dev/null; then
            error "  ✗ $tool is missing. Install with: $install_hint"
            REQUIREMENT_FAILURES+=("$tool is missing. Install with: $install_hint")
            failures=$((failures + 1))
            continue
        fi

        if [ -n "$min_version" ]; then
            local version
            version="$(installed_version "$tool")"

            if [ -z "$version" ]; then
                warning "  ? $tool found but its version could not be read (need >= $min_version)"
                continue
            fi

            if ! version_at_least "$version" "$min_version"; then
                error "  ✗ $tool $version is too old, need >= $min_version. Update with: $install_hint"
                REQUIREMENT_FAILURES+=("$tool $version is too old, need >= $min_version. Update with: $install_hint")
                failures=$((failures + 1))
                continue
            fi

            success "  ✓ $tool $version"
        else
            success "  ✓ $tool"
        fi
    done <"$config_file"

    return "$failures"
}

# Filled with one line per unmet requirement so callers can show a summary
REQUIREMENT_FAILURES=()

check_requirements() {
    local total_failures=0
    REQUIREMENT_FAILURES=()

    for config_file in "$REPO_DIR"/*/requirements.conf; do
        [ -f "$config_file" ] || continue
        check_requirements_file "$config_file"
        total_failures=$((total_failures + $?))
    done

    if [ "$total_failures" -gt 0 ]; then
        error "$total_failures requirement(s) not met."
        return 1
    fi

    success "All requirements met."
}

# Only run if script is executed, not sourced
if [ "$(basename "$0")" = "$(basename "${BASH_SOURCE[0]}")" ]; then
    check_requirements
fi
