#!/usr/bin/env bash

set -euo pipefail

module_check() {
    command -v dotnet >/dev/null 2>&1
}

module_install() {
    require_command mise "mise required (install cli-tools first)"
    
    log_info "Installing .NET SDK"
    mise use -g dotnet@latest
    
    log_info "Installing CSharpier and EasyDotnet"
    pushd "$HOME" >/dev/null
    dotnet new tool-manifest --force 2>/dev/null || true
    dotnet tool install -g csharpier
    dotnet tool install -g EasyDotnet
    popd >/dev/null
}

module_update() {
    mise upgrade dotnet
}
