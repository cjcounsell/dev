#!/usr/bin/env bash

set -euo pipefail

STEAM_DIR="$HOME/.local/share/Steam"

# Check if path is a btrfs subvolume
_is_btrfs_subvolume() {
    local path="$1"
    [[ -d "$path" ]] && sudo btrfs subvolume show "$path" >/dev/null 2>&1
}

# Check if path is on a btrfs filesystem
_is_btrfs_filesystem() {
    local path="$1"
    local check_path="$path"
    
    # Walk up to find existing parent
    while [[ ! -e "$check_path" && "$check_path" != "/" ]]; do
        check_path="$(dirname "$check_path")"
    done
    
    local fstype
    fstype=$(stat -f -c %T "$check_path" 2>/dev/null) || return 1
    [[ "$fstype" == "btrfs" ]]
}

# Setup Steam directory as btrfs subvolume (excluded from snapshots)
_setup_steam_subvolume() {
    if ! _is_btrfs_filesystem "$HOME/.local/share"; then
        log_info "Filesystem is not btrfs, skipping Steam subvolume setup"
        return 0
    fi
    
    if _is_btrfs_subvolume "$STEAM_DIR"; then
        log_info "Steam directory already a btrfs subvolume"
        return 0
    fi
    
    if [[ -d "$STEAM_DIR" ]]; then
        # Steam already installed - move data, create subvolume, restore
        log_info "Steam directory exists, migrating to subvolume..."
        local tmp_dir
        tmp_dir=$(mktemp -d)
        
        log_info "Moving existing Steam data to temp location..."
        mv "$STEAM_DIR" "$tmp_dir/Steam"
        
        log_info "Creating btrfs subvolume at $STEAM_DIR..."
        sudo btrfs subvolume create "$STEAM_DIR"
        sudo chown "$USER:$USER" "$STEAM_DIR"
        
        log_info "Restoring Steam data..."
        mv "$tmp_dir/Steam/"* "$STEAM_DIR/" 2>/dev/null || true
        mv "$tmp_dir/Steam/".* "$STEAM_DIR/" 2>/dev/null || true
        rmdir "$tmp_dir/Steam" "$tmp_dir"
        
        log_success "Steam directory migrated to btrfs subvolume"
    else
        # Fresh install - just create subvolume
        log_info "Creating btrfs subvolume at $STEAM_DIR..."
        mkdir -p "$(dirname "$STEAM_DIR")"
        sudo btrfs subvolume create "$STEAM_DIR"
        sudo chown "$USER:$USER" "$STEAM_DIR"
        log_success "Steam btrfs subvolume created"
    fi
}

module_check() {
    command -v prismlauncher >/dev/null 2>&1
}

module_install() {
    if [[ "$OS" != "arch" ]]; then
        log_warn "Gaming module only supported on Arch, skipping"
        return 0
    fi
    
    _setup_steam_subvolume
    install_packages "gaming"
}
