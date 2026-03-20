#!/usr/bin/env bash

set -euo pipefail

module_check() {
    command -v nmcli >/dev/null 2>&1 &&
        systemctl is-enabled NetworkManager >/dev/null 2>&1
}

module_install() {
    if [[ "$OS" != "arch" ]]; then
        log_warn "NetworkManager module only supported on Arch, skipping"
        return 0
    fi

    install_packages "networkmanager"

    # Disable iwd and systemd-networkd if active
    for svc in iwd systemd-networkd; do
        if systemctl is-enabled "$svc" >/dev/null 2>&1; then
            log_info "Disabling $svc"
            sudo systemctl disable --now "$svc"
        fi
    done

    # Enable NetworkManager
    if ! systemctl is-enabled NetworkManager >/dev/null 2>&1; then
        log_info "Enabling NetworkManager"
        sudo systemctl enable --now NetworkManager
    fi

    log_success "NetworkManager configured (reboot recommended)"
}
