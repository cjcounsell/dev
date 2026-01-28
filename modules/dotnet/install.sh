#!/usr/bin/env bash

set -euo pipefail

SCRIPTS_DIR="$HOME/.local/scripts"
INSTALL_SCRIPT="$SCRIPTS_DIR/dotnet-install.sh"
DOTNET_ROOT="$HOME/.dotnet"

module_check() {
    command -v dotnet >/dev/null 2>&1
}

module_install() {
    log_info "Setting up dotnet-install script"
    
    mkdir -p "$SCRIPTS_DIR"
    
    if [[ ! -f "$INSTALL_SCRIPT" ]]; then
        log_info "Downloading dotnet-install.sh"
        curl -fsSL https://dot.net/v1/dotnet-install.sh -o "$INSTALL_SCRIPT"
        chmod +x "$INSTALL_SCRIPT"
    fi
    
    log_info "Installing .NET SDK (latest LTS)"
    "$INSTALL_SCRIPT" --channel LTS
    
    export DOTNET_ROOT="$DOTNET_ROOT"
    export PATH="$DOTNET_ROOT:$DOTNET_ROOT/tools:$PATH"
    
    log_info "Installing CSharpier and EasyDotnet"
    dotnet tool install -g csharpier || dotnet tool update -g csharpier
    dotnet tool install -g EasyDotnet || dotnet tool update -g EasyDotnet
}

module_update() {
    if [[ -x "$INSTALL_SCRIPT" ]]; then
        log_info "Updating .NET SDK"
        "$INSTALL_SCRIPT" --channel LTS
    else
        log_warn "dotnet-install.sh not found, run install first"
    fi
}
