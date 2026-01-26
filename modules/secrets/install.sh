#!/usr/bin/env bash

set -euo pipefail

module_check() {
    command -v bw >/dev/null 2>&1
}

module_install() {
    case "$OS" in
        arch)
            install_packages "secrets"
            ;;
        ubuntu)
            log_info "Installing Bitwarden CLI via npm"
            npm install -g @bitwarden/cli
            ;;
    esac
    
    log_info "Bitwarden CLI installed"
    echo "Run 'bw login' to authenticate"
}

fetch_secrets() {
    bw_ensure_session
    
    mkdir -p "$HOME/.secrets"
    chmod 700 "$HOME/.secrets"
    
    if [[ -n "${BW_GH_MCP_TOKEN_ID:-}" ]]; then
        log_info "Fetching GitHub MCP token"
        bw get item "$BW_GH_MCP_TOKEN_ID" | jq -r '.fields[] | select(.name=="Token") | .value' > "$HOME/.secrets/gh_mcp_token"
        chmod 600 "$HOME/.secrets/gh_mcp_token"
    fi
    
    log_success "Secrets retrieved"
}
