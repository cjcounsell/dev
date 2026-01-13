#!/usr/bin/env bash
# State tracking for installed modules and sync status
# Uses simple key=value format (no external dependencies)

STATE_FILE="$DEV_ROOT/.local/state"

# ============================================================================
# State File Management
# ============================================================================

state_init() {
    mkdir -p "$DEV_ROOT/.local"
    touch "$STATE_FILE" 2>/dev/null || true
}

state_get() {
    local key="$1"
    grep "^${key}=" "$STATE_FILE" 2>/dev/null | cut -d'=' -f2- || true
}

state_set() {
    local key="$1"
    local value="$2"
    
    # Create temp file without the key
    grep -v "^${key}=" "$STATE_FILE" > "$STATE_FILE.tmp" 2>/dev/null || true
    
    # Add new entry
    echo "${key}=${value}" >> "$STATE_FILE.tmp"
    
    mv "$STATE_FILE.tmp" "$STATE_FILE"
}

state_remove() {
    local key="$1"
    grep -v "^${key}=" "$STATE_FILE" > "$STATE_FILE.tmp" 2>/dev/null || true
    mv "$STATE_FILE.tmp" "$STATE_FILE"
}

# ============================================================================
# Module State
# ============================================================================

module_is_installed() {
    local module="$1"
    [[ -n "$(state_get "module_${module}")" ]]
}

module_mark_installed() {
    local module="$1"
    state_set "module_${module}" "$(date -Iseconds)"
}

module_mark_uninstalled() {
    local module="$1"
    state_remove "module_${module}"
}

module_install_date() {
    local module="$1"
    state_get "module_${module}"
}

# ============================================================================
# Sync State
# ============================================================================

sync_get_hash() {
    state_get "dotfiles_hash"
}

sync_set_hash() {
    local hash="$1"
    state_set "dotfiles_hash" "$hash"
    state_set "last_sync" "$(date -Iseconds)"
}

sync_get_last() {
    state_get "last_sync"
}
