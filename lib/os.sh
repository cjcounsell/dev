#!/usr/bin/env bash
# OS detection and package manager abstraction

detect_os() {
    if [[ -f /etc/arch-release ]]; then
        echo "arch"
    elif [[ -f /etc/os-release ]] && grep -qi "ubuntu" /etc/os-release; then
        echo "ubuntu"
    else
        echo "unknown"
    fi
}

detect_environment() {
    if [[ -d "/mnt/c/Windows" ]] || grep -qi microsoft /proc/version 2>/dev/null; then
        echo "wsl"
    else
        echo "native"
    fi
}

# ============================================================================
# Package Manager Abstraction
# ============================================================================

pkg_install() {
    local packages=("$@")
    
    [[ ${#packages[@]} -eq 0 ]] && return 0
    
    log_info "Installing packages: ${packages[*]}"
    
    if [[ "${DRY_RUN:-0}" == "1" ]]; then
        log_dry "Would install: ${packages[*]}"
        return 0
    fi
    
    case "$OS" in
        arch)
            if command -v paru >/dev/null 2>&1 && paru --version >/dev/null 2>&1; then
                paru -S --noconfirm --needed "${packages[@]}"
            else
                sudo pacman -S --noconfirm --needed "${packages[@]}"
            fi
            ;;
        ubuntu)
            sudo apt-get update || error_exit "apt-get update failed. Check network connection."
            sudo apt-get install -y "${packages[@]}"
            ;;
        *)
            error_exit "Unsupported OS: $OS"
            ;;
    esac
}

pkg_update() {
    log_info "Updating system packages"
    
    if [[ "${DRY_RUN:-0}" == "1" ]]; then
        log_dry "Would run system update"
        return 0
    fi
    
    case "$OS" in
        arch)
            if command -v paru >/dev/null 2>&1 && paru --version >/dev/null 2>&1; then
                paru -Syu --noconfirm
            else
                sudo pacman -Syu --noconfirm
            fi
            ;;
        ubuntu)
            sudo apt-get update
            sudo apt-get upgrade -y
            ;;
        *)
            error_exit "Unsupported OS: $OS"
            ;;
    esac
}

# ============================================================================
# Package Installation from Config
# ============================================================================

# Install packages for a category from packages.conf
# Usage: install_packages "cli"
# This will install cli_common + cli_$OS packages
install_packages() {
    local category="$1"
    local common_var="${category}_common"
    local os_var="${category}_${OS}"
    
    local packages=()
    
     # Add common packages if defined
     if declare -p "$common_var" &>/dev/null; then
         declare -n _ref="$common_var"
         packages+=("${_ref[@]}")
         unset -n _ref
     fi
     
     # Add OS-specific packages if defined
     if declare -p "$os_var" &>/dev/null; then
         declare -n _ref="$os_var"
         packages+=("${_ref[@]}")
         unset -n _ref
     fi
    
    if [[ ${#packages[@]} -eq 0 ]]; then
        log_debug "No packages found for category: $category"
        return 0
    fi
    
    pkg_install "${packages[@]}"
}
