#!/bin/bash

# Boots a fresh vanilla macOS VM with tart and runs the README first-run
# flow inside, then asserts the machine came out configured. The pristine
# image stays in tart's OCI cache and is never modified; every run clones
# it again, so each run is a genuinely fresh machine.
#
# Usage:
#   ./scripts/tests/vm/test-macos.sh [--ref <branch>] [--keep] [--fresh-image]
#
#   --ref <branch>   Install from this branch's tarball (default: main)
#   --keep           Leave the VM running after the test for inspection
#   --fresh-image    Re-download the macOS image (about 25 GB)
#
# Requires an Apple Silicon Mac with Homebrew; tart and sshpass are
# installed by the preflight when missing.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. "$SCRIPT_DIR/../../utils.sh"

CACHE_DIR="${DOTFILES_VMTEST_DIR:-$HOME/.cache/dotfiles-vmtest}"
IMAGE="ghcr.io/cirruslabs/macos-tahoe-vanilla:latest"
VM_NAME=dotfiles-vmtest
# The cirruslabs vanilla images ship this user with passwordless sudo
VM_USER=admin
VM_PASSWORD=admin

REF=main
KEEP=false
FRESH_IMAGE=false

while [ $# -gt 0 ]; do
    case "$1" in
    --ref)
        REF="$2"
        shift 2
        ;;
    --keep)
        KEEP=true
        shift
        ;;
    --fresh-image)
        FRESH_IMAGE=true
        shift
        ;;
    *)
        error "Unknown argument: $1 (see the header of this script)"
        exit 1
        ;;
    esac
done

ssh_vm() {
    sshpass -p "$VM_PASSWORD" ssh \
        -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
        -o ConnectTimeout=5 -o LogLevel=ERROR \
        "$VM_USER@$VM_IP" "$@"
}

preflight() {
    if [ "$(detect_os)" != "macos" ] || [ "$(uname -m)" != "arm64" ]; then
        error "tart needs an Apple Silicon Mac; this is $(uname -s) $(uname -m)"
        exit 1
    fi

    if ! command -v brew &>/dev/null; then
        error "Missing: brew. This test needs Homebrew on the host."
        exit 1
    fi

    command -v tart &>/dev/null || install_tart
    command -v sshpass &>/dev/null || install_sshpass
}

# The cirruslabs tap needs trust on Homebrew 7, and its formulas still use a
# depends_on form Homebrew 7 rejects; patch the two files for the install
# and restore the tap afterwards
install_tart() {
    info "Installing tart from the cirruslabs tap…"
    brew tap cirruslabs/cli >/dev/null 2>&1
    brew trust cirruslabs/cli >/dev/null 2>&1

    if ! brew install cirruslabs/cli/tart >/dev/null 2>&1; then
        local tap_dir
        tap_dir="$(brew --repository cirruslabs/cli)"
        warning "Plain install failed; patching the tap's depends_on lines and retrying…"
        sed -i '' '/depends_on :macos => /d' "$tap_dir/tart.rb" "$tap_dir/softnet.rb"
        brew install cirruslabs/cli/tart
        local status=$?
        git -C "$tap_dir" checkout -q -- tart.rb softnet.rb
        if [ "$status" -ne 0 ]; then
            error "tart failed to install; see https://github.com/cirruslabs/homebrew-cli"
            exit 1
        fi
    fi
    success "tart installed"
}

install_sshpass() {
    info "Installing sshpass…"
    if ! brew install hudochenkov/sshpass/sshpass >/dev/null 2>&1; then
        error "sshpass failed to install: brew install hudochenkov/sshpass/sshpass"
        exit 1
    fi
    success "sshpass installed"
}

prepare_image() {
    mkdir -p "$CACHE_DIR"

    if [ "$FRESH_IMAGE" = true ]; then
        tart delete "$IMAGE" 2>/dev/null
    fi
    if ! tart list 2>/dev/null | grep -q "$IMAGE"; then
        info "Pulling the macOS image (about 25 GB, cached by tart for later runs)…"
        if ! tart pull "$IMAGE"; then
            error "Image pull failed"
            exit 1
        fi
    fi
}

stop_vm() {
    if tart list 2>/dev/null | grep -q "^local *$VM_NAME "; then
        tart stop "$VM_NAME" 2>/dev/null
        sleep 2
        tart delete "$VM_NAME" 2>/dev/null
    fi
}

boot_vm() {
    stop_vm
    info "Cloning a fresh VM from the image…"
    tart clone "$IMAGE" "$VM_NAME" || exit 1

    info "Booting the VM (headless)…"
    nohup tart run --no-graphics "$VM_NAME" >"$CACHE_DIR/tart.log" 2>&1 &

    info "Waiting for the VM to get an IP and accept ssh…"
    local i
    for i in $(seq 1 36); do
        VM_IP="$(tart ip "$VM_NAME" 2>/dev/null)"
        if [ -n "$VM_IP" ] && ssh_vm true 2>/dev/null; then
            success "VM is up at $VM_IP"
            return
        fi
        sleep 5
    done

    error "VM did not become reachable over ssh; see $CACHE_DIR/tart.log"
    exit 1
}

run_install() {
    LOG_FILE="$CACHE_DIR/run-macos-$(date +%Y%m%d-%H%M%S).log"
    info "Running the README first-run flow from ref '$REF' (log: $LOG_FILE)…"
    info "This takes a few minutes: Command Line Tools, Homebrew, casks and formulas."

    ssh_vm 'mkdir -p ~/dev && curl -fsSL https://github.com/Klynger/dotfiles/archive/refs/heads/'"$REF"'.tar.gz | tar xz -C ~/dev && mv ~/dev/dotfiles-* ~/dev/dotfiles && cd ~/dev/dotfiles && ./install.sh --yes' \
        >"$LOG_FILE" 2>&1
    INSTALL_EXIT=$?
}

# Everything the manual VM runs taught us to check, as hard assertions
run_assertions() {
    FAILURES=0

    flunk() {
        error "ASSERT: $1"
        FAILURES=$((FAILURES + 1))
    }

    [ "$INSTALL_EXIT" -eq 0 ] || flunk "install.sh exited with $INSTALL_EXIT"

    grep -q "Dotfiles set up successfully" "$LOG_FILE" ||
        flunk "success line missing from the log"

    local bad
    bad=$(grep -cE "failed to install, continuing|Finish the Command Line Tools dialog|command not found|tap trust is required" "$LOG_FILE")
    [ "$bad" -eq 0 ] || flunk "$bad failure/dialog lines in the log"

    # Machine-level checks inside the VM; each problem comes back as a line.
    # Non-login ssh shells have no Homebrew on PATH, hence the shellenv.
    local missing
    missing=$(ssh_vm '
        eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null
        for f in ~/.zshrc ~/.config/nvim ~/.tmux.conf ~/.wezterm.lua ~/.config/yazi ~/.claude/CLAUDE.md; do
            [ -L "$f" ] && [ -e "$f" ] || echo "missing or dangling: $f"
        done
        [ "$(readlink ~/.zshrc)" = "$HOME/dev/dotfiles/zsh/.zshrc" ] || echo "~/.zshrc is not the tracked one"
        for t in brew nvim tmux fzf yazi zsh node tree-sitter go mpv rg shfmt wezterm; do
            command -v "$t" >/dev/null || echo "brew tool missing: $t"
        done
        brew list --versions powerlevel10k >/dev/null 2>&1 || echo "powerlevel10k not installed"
        [ "$(brew list --cask 2>/dev/null | grep -c "^font-")" -ge 4 ] || echo "fewer than 4 font casks"
        [ -d ~/.oh-my-zsh ] || echo "oh-my-zsh missing"
        [ -d ~/dev/dotfiles/tmux/plugins/tpm ] || echo "tpm missing"
        zsh -i -c "whence -w p10k _zsh_autosuggest_start _zsh_highlight y" 2>/dev/null | grep -q none && echo "interactive zsh did not load the full stack"
        tmux -L vmtest -f ~/.tmux.conf new-session -d 2>/dev/null || echo "tmux config failed to load"
        [ "$(tmux -L vmtest show-options -sv copy-command 2>/dev/null)" = pbcopy ] || echo "tmux copy-command is not pbcopy"
        tmux -L vmtest kill-server 2>/dev/null
        nvim --headless "+Lazy! restore" +qa >/dev/null 2>&1
        [ "$(ls ~/.local/share/nvim/lazy 2>/dev/null | wc -l)" -ge 50 ] || echo "fewer than 50 nvim plugins installed"' 2>/dev/null)
    if [ -n "$missing" ]; then
        while IFS= read -r line; do
            flunk "$line"
        done <<<"$missing"
    fi
}

preflight
prepare_image
boot_vm
run_install
run_assertions

if [ "$KEEP" = true ]; then
    warning "VM left running: sshpass -p $VM_PASSWORD ssh $VM_USER@$VM_IP (tart delete $VM_NAME when done)"
else
    stop_vm
fi

if [ "$FAILURES" -gt 0 ]; then
    error "macOS VM test FAILED with $FAILURES assertion(s); log: $LOG_FILE"
    exit 1
fi
success "macOS VM test passed; log: $LOG_FILE"
