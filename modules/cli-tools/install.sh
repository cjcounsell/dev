#!/usr/bin/env bash

set -euo pipefail

module_check() {
    command -v fzf >/dev/null 2>&1 && \
    command -v rg >/dev/null 2>&1 && \
    command -v eza >/dev/null 2>&1 && \
    command -v mise >/dev/null 2>&1
}

module_install() {
    install_packages "cli"
    
    if [[ "$OS" == "ubuntu" ]]; then
        mkdir -p "$HOME/.local/bin"
        
        # Create convenience symlinks for Ubuntu package renames (optional, not errors)
        if command -v fdfind >/dev/null 2>&1; then
            ln -sf "$(which fdfind)" "$HOME/.local/bin/fd"
        fi
        if command -v batcat >/dev/null 2>&1; then
            ln -sf "$(which batcat)" "$HOME/.local/bin/bat"
        fi
        
        if ! command -v mise >/dev/null 2>&1; then
            log_info "Installing mise"
            sudo install -dm 755 /etc/apt/keyrings
            wget -qO - https://mise.jdx.dev/gpg-key.pub | gpg --dearmor | sudo tee /etc/apt/keyrings/mise-archive-keyring.gpg 1>/dev/null
            echo "deb [signed-by=/etc/apt/keyrings/mise-archive-keyring.gpg arch=amd64] https://mise.jdx.dev/deb stable main" | sudo tee /etc/apt/sources.list.d/mise.list
            sudo apt-get update
            sudo apt-get install -y mise
        fi

        if ! command -v eza >/dev/null 2>&1; then
            log_info "Installing eza"
            sudo mkdir -p /etc/apt/keyrings
            wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
            echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
            sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
            sudo apt-get update
            sudo apt-get install -y eza
        fi
    fi
}
