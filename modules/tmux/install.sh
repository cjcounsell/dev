#!/usr/bin/env bash

set -euo pipefail

module_check() {
    command -v tmux >/dev/null 2>&1
}

module_install() {
    install_packages "tmux"
}
