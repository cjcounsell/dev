#!/usr/bin/env bash

set -euo pipefail

module_check() {
    command -v php >/dev/null 2>&1
}

module_install() {
    log_info "Installing PHP via Herd"
    local herd_installer
    herd_installer=$(mktemp)
    curl -fsSL https://herd.laravel.com/install/linux -o "$herd_installer" || error_exit "Failed to download Herd installer"
    bash "$herd_installer" || error_exit "Failed to install Herd"
    rm -f "$herd_installer"
    
    if [[ -n "${BW_INTELEPHENSE_ID:-}" ]]; then
        bw_ensure_session
        
        log_info "Fetching Intelephense license"
        mkdir -p "$HOME/intelephense"
        bw get item "$BW_INTELEPHENSE_ID" | jq -r '.fields[] | select(.name=="Licence Key") | .value' > "$HOME/intelephense/licence.txt"
        chmod 600 "$HOME/intelephense/licence.txt"
    else
        log_warn "BW_INTELEPHENSE_ID not set, skipping license fetch"
    fi
}
