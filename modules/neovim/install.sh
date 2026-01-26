#!/usr/bin/env bash

set -euo pipefail

module_check() {
    command -v nvim >/dev/null 2>&1 || \
    [[ -x "/opt/nvim-linux-x86_64/bin/nvim" ]]
}

module_install() {
    case "$OS" in
        arch)
            install_packages "neovim"
            ;;
        ubuntu)
            log_info "Installing Neovim from GitHub releases"
            pushd "$HOME" >/dev/null || error_exit "Failed to cd to HOME"
            curl -fLO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz || error_exit "Failed to download Neovim"
            sudo rm -rf /opt/nvim
            sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz || error_exit "Failed to extract Neovim"
            rm nvim-linux-x86_64.tar.gz
            popd >/dev/null || true
            ;;
    esac
}
