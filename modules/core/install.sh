#!/usr/bin/env bash

module_check() {
    command -v git >/dev/null 2>&1
}

module_install() {
    install_packages "core"
    
    if [[ "$OS" == "arch" ]] && ! command -v paru >/dev/null 2>&1; then
        log_info "Installing paru"
        local paru_dir="$HOME/paru"
        [[ -d "$paru_dir" ]] && rm -rf "$paru_dir"
        git clone https://aur.archlinux.org/paru.git "$paru_dir"
        pushd "$paru_dir" >/dev/null
        makepkg -si --noconfirm
        popd >/dev/null
        rm -rf "$paru_dir"
    fi
}
