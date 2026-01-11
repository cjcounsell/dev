#!/usr/bin/env bash

module_check() {
    command -v zsh >/dev/null 2>&1 && \
    [[ -d "$HOME/.oh-my-zsh" ]] && \
    command -v starship >/dev/null 2>&1
}

module_install() {
    install_packages "shell"
    
    if [[ "$OS" == "ubuntu" ]] && ! command -v starship >/dev/null 2>&1; then
        log_info "Installing Starship"
        curl -sS https://starship.rs/install.sh | sh -s -- -y
    fi
    
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        log_info "Installing Oh-My-Zsh"
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
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
