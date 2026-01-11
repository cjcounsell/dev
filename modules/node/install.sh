#!/usr/bin/env bash

module_check() {
    command -v node >/dev/null 2>&1 && \
    node -v 2>/dev/null | grep -q "^v2[4-9]"
}

module_install() {
    require_command mise "mise required (install cli-tools first)"
    
    log_info "Installing Node.js 24"
    mise use -g node@24
    
    log_info "Installing neovim npm package"
    npm install -g neovim
}

module_update() {
    mise upgrade node
}
