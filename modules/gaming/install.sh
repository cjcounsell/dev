#!/usr/bin/env bash

set -euo pipefail

module_check() {
    command -v prismlauncher >/dev/null 2>&1
}

module_install() {
    if [[ "$OS" != "arch" ]]; then
        log_warn "Gaming module only supported on Arch, skipping"
        return 0
    fi
    
    install_packages "gaming"
}
