#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$BASH_SOURCE[0]}")" && pwd)"

. $SCRIPT_DIR/macos.sh
. $SCRIPT_DIR/ubuntu.sh
. $SCRIPT_DIR/utils.sh

install_prerequisites() {
    OS=$(detect_os)
    case $OS in
    "macos")
        info "Detected MacOS 🍎"
        install_macos_prerequisites
        ;;
    "ubuntu")
        info "Detected Ubuntu 🐧"
        install_ubuntu_prerequisites
        ;;
    *)
        error "Unsupported OS: $OS"
        exit 1
        ;;
    esac
}
