#!/usr/bin/env bash

module_check() {
    command -v hyprctl >/dev/null 2>&1
}

module_install() {
    if [[ "$OS" != "arch" ]]; then
        log_warn "Desktop module only supported on Arch"
        return 0
    fi
    
    install_packages "desktop"
}
