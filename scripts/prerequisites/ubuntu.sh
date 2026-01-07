#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$BASH_SOURCE[0]}")" && pwd)"
. $SCRIPT_DIR/utils.sh

install_ubuntu_prerequisites() {
    info "💿 Installing Ubuntu prerequisites…"
    sudo apt update
    sudo apt install -y curl wget git build-essential software-properties-common
}
