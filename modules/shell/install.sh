#!/usr/bin/env bash

set -euo pipefail

module_check() {
    command -v zsh >/dev/null 2>&1 && \
    [[ -d "$HOME/.oh-my-zsh" ]] && \
    command -v starship >/dev/null 2>&1
}

module_install() {
    install_packages "shell"
    
    if [[ "$OS" == "ubuntu" ]] && ! command -v starship >/dev/null 2>&1; then
        log_info "Installing Starship"
        local starship_installer
        starship_installer=$(mktemp)
        curl -fsSL https://starship.rs/install.sh -o "$starship_installer" || error_exit "Failed to download Starship installer"
        sh "$starship_installer" -s -- -y || error_exit "Failed to install Starship"
        rm -f "$starship_installer"
    fi
    
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        log_info "Installing Oh-My-Zsh"
        local omz_installer
        omz_installer=$(mktemp)
        curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -o "$omz_installer" || error_exit "Failed to download Oh-My-Zsh installer"
        sh "$omz_installer" --unattended || error_exit "Failed to install Oh-My-Zsh"
        rm -f "$omz_installer"
    fi
    
    local autosuggestions_dir="$HOME/.zsh/zsh-autosuggestions"
    if [[ ! -d "$autosuggestions_dir" ]]; then
        log_info "Installing zsh-autosuggestions"
        mkdir -p "$HOME/.zsh"
        git clone https://github.com/zsh-users/zsh-autosuggestions "$autosuggestions_dir"
    fi
    
    if [[ "$SHELL" != */zsh ]]; then
        log_info "Setting zsh as default shell"
        chsh -s /bin/zsh
    fi
}
