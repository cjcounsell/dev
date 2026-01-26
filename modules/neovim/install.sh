#!/usr/bin/env bash

set -euo pipefail

module_check() {
    command -v nvim >/dev/null 2>&1
}

module_install() {
    case "$OS" in
        arch)
            install_packages "neovim"
            ;;
        ubuntu)
            log_info "Installing Neovim from GitHub releases"
            pushd "$HOME" >/dev/null
            curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
            sudo rm -rf /opt/nvim
            sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
            rm nvim-linux-x86_64.tar.gz
            popd >/dev/null
            ;;
    esac
}
