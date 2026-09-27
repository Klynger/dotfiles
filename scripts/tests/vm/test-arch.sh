#!/bin/bash

# Boots a fresh vanilla Arch VM and runs the README first-run flow inside,
# then asserts the machine came out configured. The pristine cloud image is
# cached in ~/.cache/dotfiles-vmtest and never modified; every run starts
# from a clean overlay, so each run is a genuinely fresh machine.
#
# Usage:
#   ./scripts/tests/vm/test-arch.sh [--ref <branch>] [--keep] [--fresh-image]
#
#   --ref <branch>   Install from this branch's tarball (default: main)
#   --keep           Leave the VM running after the test for inspection
#   --fresh-image    Re-download the Arch cloud image
#
# Requires qemu-base, cloud-image-utils and working KVM (/dev/kvm).

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. "$SCRIPT_DIR/../../utils.sh"

CACHE_DIR="${DOTFILES_VMTEST_DIR:-$HOME/.cache/dotfiles-vmtest}"
IMAGE_URL="https://geo.mirror.pkgbuild.com/images/latest/Arch-Linux-x86_64-cloudimg.qcow2"
SSH_PORT=2222
RAM_MB=8192 # the paru source build OOMs with 4GB
CPUS=4
DISK_SIZE=40G
VM_USER=tester

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
    ssh -i "$CACHE_DIR/vmkey" -p "$SSH_PORT" \
        -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
        -o ConnectTimeout=5 -o LogLevel=ERROR \
        "$VM_USER@localhost" "$@"
}

preflight() {
    local missing=false
    local tool
    for tool in qemu-system-x86_64 qemu-img cloud-localds ssh-keygen curl; do
        if ! command -v "$tool" &>/dev/null; then
            error "Missing: $tool"
            missing=true
        fi
    done
    if [ "$missing" = true ]; then
        error "Install the tooling with: sudo pacman -S --needed qemu-base cloud-image-utils"
        exit 1
    fi

    if [ ! -e /dev/kvm ]; then
        error "/dev/kvm not found. Load KVM (sudo modprobe kvm_amd or kvm_intel);"
        error "if that reports 'Operation not supported', enable SVM/VT-x in the BIOS."
        exit 1
    fi
}

prepare_image() {
    mkdir -p "$CACHE_DIR"

    if [ "$FRESH_IMAGE" = true ]; then
        rm -f "$CACHE_DIR/arch-cloudimg.qcow2"
    fi
    if [ ! -f "$CACHE_DIR/arch-cloudimg.qcow2" ]; then
        info "Downloading the Arch cloud image (cached for later runs)…"
        if ! curl -fL -o "$CACHE_DIR/arch-cloudimg.qcow2" "$IMAGE_URL"; then
            error "Image download failed"
            exit 1
        fi
    fi

    if [ ! -f "$CACHE_DIR/vmkey" ]; then
        ssh-keygen -q -t ed25519 -N "" -f "$CACHE_DIR/vmkey"
    fi

    cat >"$CACHE_DIR/user-data" <<EOF
#cloud-config
hostname: archtest
users:
  - name: $VM_USER
    groups: wheel
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    ssh_authorized_keys:
      - $(cat "$CACHE_DIR/vmkey.pub")
ssh_pwauth: false
EOF
    printf 'instance-id: archtest-1\nlocal-hostname: archtest\n' >"$CACHE_DIR/meta-data"
    cloud-localds "$CACHE_DIR/seed.img" "$CACHE_DIR/user-data" "$CACHE_DIR/meta-data"
}

stop_vm() {
    if [ -f "$CACHE_DIR/qemu.pid" ]; then
        kill "$(cat "$CACHE_DIR/qemu.pid")" 2>/dev/null
        rm -f "$CACHE_DIR/qemu.pid"
        sleep 2
    fi
}

boot_vm() {
    stop_vm
    rm -f "$CACHE_DIR/disk.qcow2"
    qemu-img create -q -f qcow2 -b "$CACHE_DIR/arch-cloudimg.qcow2" -F qcow2 \
        "$CACHE_DIR/disk.qcow2" "$DISK_SIZE"

    info "Booting the VM ($RAM_MB MB RAM, $CPUS cpus, ssh on port $SSH_PORT)…"
    qemu-system-x86_64 -enable-kvm -cpu host -m "$RAM_MB" -smp "$CPUS" \
        -drive file="$CACHE_DIR/disk.qcow2",if=virtio \
        -drive file="$CACHE_DIR/seed.img",if=virtio,format=raw \
        -netdev user,id=n0,hostfwd=tcp::"$SSH_PORT"-:22 -device virtio-net-pci,netdev=n0 \
        -display none -serial file:"$CACHE_DIR/serial.log" \
        -daemonize -pidfile "$CACHE_DIR/qemu.pid"

    info "Waiting for cloud-init and sshd…"
    local i
    for i in $(seq 1 36); do
        if ssh_vm true 2>/dev/null; then
            success "VM is up"
            return
        fi
        sleep 5
    done

    error "VM did not become reachable over ssh; see $CACHE_DIR/serial.log"
    exit 1
}

run_install() {
    LOG_FILE="$CACHE_DIR/run-$(date +%Y%m%d-%H%M%S).log"
    info "Running the README first-run flow from ref '$REF' (log: $LOG_FILE)…"
    info "This takes a while: full pacman desktop, paru built from source, linuxbrew."

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
    bad=$(grep -cE "failed to install, continuing|failed, continuing|failed to build|Will wait for connection" "$LOG_FILE")
    [ "$bad" -eq 0 ] || flunk "$bad failure/hang lines in the log"

    # File-level checks inside the VM; each missing path comes back as a line
    local missing
    missing=$(ssh_vm '
        for f in ~/.zshrc ~/.config/nvim ~/.config/hypr ~/.config/waybar \
            ~/.tmux.conf ~/.config/hypr/monitors.lua ~/.config/hypr/colors.lua \
            ~/.config/waybar/matugen/colors.css \
            /usr/share/sddm/themes/material-you/Main.qml; do
            [ -e "$f" ] || echo "$f"
        done
        [ "$(ls ~/.local/bin | wc -l)" -ge 10 ] || echo "~/.local/bin has too few helpers"
        export PATH=/home/linuxbrew/.linuxbrew/bin:$PATH
        for t in nvim tmux fzf yazi zsh; do
            command -v "$t" >/dev/null || echo "brew tool missing: $t"
        done' 2>/dev/null)
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
    warning "VM left running: ssh -i $CACHE_DIR/vmkey -p $SSH_PORT $VM_USER@localhost"
else
    stop_vm
fi

if [ "$FAILURES" -gt 0 ]; then
    error "Arch VM test FAILED with $FAILURES assertion(s); log: $LOG_FILE"
    exit 1
fi
success "Arch VM test passed; log: $LOG_FILE"
