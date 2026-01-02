#!/usr/bin/env bash
# Common utilities for dev environment scripts
# Source this file: source "$DEV_ENV/utils/common.sh"

# ============================================================================
# Configuration
# ============================================================================
BACKUP_DIR="${BACKUP_DIR:-$HOME/.config-backups}"
LOG_LEVEL="${LOG_LEVEL:-INFO}"  # DEBUG, INFO, WARN, ERROR
DRY_RUN="${DRY_RUN:-0}"

# Color codes (disabled if not a terminal)
if [[ -t 1 ]]; then
    _RED='\033[0;31m'
    _GREEN='\033[0;32m'
    _YELLOW='\033[0;33m'
    _BLUE='\033[0;34m'
    _GRAY='\033[0;90m'
    _NC='\033[0m'
else
    _RED='' _GREEN='' _YELLOW='' _BLUE='' _GRAY='' _NC=''
fi

# ============================================================================
# Logging Functions
# ============================================================================
_log_level_num() {
    case "$1" in
        DEBUG) echo 0 ;;
        INFO)  echo 1 ;;
        WARN)  echo 2 ;;
        ERROR) echo 3 ;;
        *)     echo 1 ;;
    esac
}

_should_log() {
    local level="$1"
    local current_level_num=$(_log_level_num "$LOG_LEVEL")
    local msg_level_num=$(_log_level_num "$level")
    [[ $msg_level_num -ge $current_level_num ]]
}

log_debug() {
    _should_log "DEBUG" && echo -e "${_GRAY}[DEBUG]${_NC} $*"
}

log_info() {
    _should_log "INFO" && echo -e "${_BLUE}[INFO]${_NC} $*"
}

log_warn() {
    _should_log "WARN" && echo -e "${_YELLOW}[WARN]${_NC} $*" >&2
}

log_error() {
    _should_log "ERROR" && echo -e "${_RED}[ERROR]${_NC} $*" >&2
}

log_success() {
    _should_log "INFO" && echo -e "${_GREEN}[OK]${_NC} $*"
}

log_dry() {
    echo -e "${_YELLOW}[DRY_RUN]${_NC} $*"
}

# Convenience wrapper that respects dry_run
log() {
    if [[ "${DRY_RUN:-0}" == "1" ]]; then
        log_dry "$*"
    else
        log_info "$*"
    fi
}

# ============================================================================
# Error Handling
# ============================================================================
error_exit() {
    log_error "$1"
    exit "${2:-1}"
}

# Trap handler for cleanup on error
_cleanup_on_error() {
    local exit_code=$?
    if [[ $exit_code -ne 0 ]]; then
        log_error "Script failed with exit code $exit_code"
        if [[ -n "${_LAST_BACKUP_DIR:-}" && -d "$_LAST_BACKUP_DIR" ]]; then
            log_warn "Backup available at: $_LAST_BACKUP_DIR"
        fi
    fi
}

# Enable error trap (call this after sourcing)
enable_error_trap() {
    trap _cleanup_on_error EXIT
}

# ============================================================================
# Backup Functions
# ============================================================================
_LAST_BACKUP_DIR=""
_BACKUP_SESSION_DIR=""

# Initialize backup session (call once at start of script)
init_backup_session() {
    local session_name="${1:-$(date +%Y%m%d-%H%M%S)}"
    _BACKUP_SESSION_DIR="$BACKUP_DIR/$session_name"
    
    if [[ "${DRY_RUN:-0}" == "0" ]]; then
        mkdir -p "$_BACKUP_SESSION_DIR"
        _LAST_BACKUP_DIR="$_BACKUP_SESSION_DIR"
        log_debug "Backup session initialized: $_BACKUP_SESSION_DIR"
    else
        log_dry "Would create backup session: $BACKUP_DIR/$session_name"
    fi
}

# Backup a file or directory before modifying
backup_item() {
    local item="$1"
    
    if [[ ! -e "$item" ]]; then
        log_debug "Nothing to backup (doesn't exist): $item"
        return 0
    fi
    
    if [[ -z "$_BACKUP_SESSION_DIR" ]]; then
        init_backup_session
    fi
    
    # Preserve directory structure in backup
    local relative_path="${item#$HOME/}"
    local backup_path="$_BACKUP_SESSION_DIR/$relative_path"
    local backup_parent
    backup_parent="$(dirname "$backup_path")"
    
    if [[ "${DRY_RUN:-0}" == "0" ]]; then
        mkdir -p "$backup_parent"
        if [[ -d "$item" ]]; then
            cp -rp "$item" "$backup_path"
        else
            cp -p "$item" "$backup_path"
        fi
        log_debug "Backed up: $item -> $backup_path"
    else
        log_dry "Would backup: $item -> $backup_path"
    fi
}

# List all backups
list_backups() {
    if [[ -d "$BACKUP_DIR" ]]; then
        log_info "Available backups in $BACKUP_DIR:"
        ls -lt "$BACKUP_DIR" | head -20
    else
        log_info "No backups found"
    fi
}

# Restore from a backup session
restore_backup() {
    local session="$1"
    local backup_path="$BACKUP_DIR/$session"
    
    if [[ ! -d "$backup_path" ]]; then
        error_exit "Backup session not found: $backup_path"
    fi
    
    log_info "Restoring from backup: $backup_path"
    
    # Find all files in backup and restore to original locations
    while IFS= read -r -d '' file; do
        local relative="${file#$backup_path/}"
        local dest="$HOME/$relative"
        local dest_parent
        dest_parent="$(dirname "$dest")"
        
        if [[ "${DRY_RUN:-0}" == "0" ]]; then
            mkdir -p "$dest_parent"
            cp -rp "$file" "$dest"
            log_debug "Restored: $file -> $dest"
        else
            log_dry "Would restore: $file -> $dest"
        fi
    done < <(find "$backup_path" -type f -print0)
    
    log_success "Restore complete"
}

# Clean old backups (keep last N)
cleanup_old_backups() {
    local keep="${1:-5}"
    
    if [[ ! -d "$BACKUP_DIR" ]]; then
        return 0
    fi
    
    local count
    count=$(find "$BACKUP_DIR" -mindepth 1 -maxdepth 1 -type d | wc -l)
    
    if [[ $count -le $keep ]]; then
        log_debug "Only $count backups exist, keeping all"
        return 0
    fi
    
    local to_remove=$((count - keep))
    log_info "Cleaning up $to_remove old backup(s), keeping $keep"
    
    if [[ "${DRY_RUN:-0}" == "0" ]]; then
        find "$BACKUP_DIR" -mindepth 1 -maxdepth 1 -type d -printf '%T+ %p\n' | \
            sort | head -n "$to_remove" | cut -d' ' -f2- | \
            while read -r dir; do
                rm -rf "$dir"
                log_debug "Removed old backup: $dir"
            done
    else
        log_dry "Would remove $to_remove oldest backup(s)"
    fi
}

# ============================================================================
# Validation Functions
# ============================================================================
require_var() {
    local var_name="$1"
    local var_value="${!var_name:-}"
    
    if [[ -z "$var_value" ]]; then
        error_exit "Required environment variable not set: $var_name"
    fi
}

require_command() {
    local cmd="$1"
    if ! command -v "$cmd" >/dev/null 2>&1; then
        error_exit "Required command not found: $cmd"
    fi
}

require_dir() {
    local dir="$1"
    if [[ ! -d "$dir" ]]; then
        error_exit "Required directory not found: $dir"
    fi
}

require_file() {
    local file="$1"
    if [[ ! -f "$file" ]]; then
        error_exit "Required file not found: $file"
    fi
}

require_writable() {
    local path="$1"
    if [[ ! -w "$path" ]]; then
        error_exit "No write permission: $path"
    fi
}

# Check disk space (in MB)
require_disk_space() {
    local required_mb="${1:-100}"
    local path="${2:-$HOME}"
    
    local available_kb
    available_kb=$(df -k "$path" | awk 'NR==2 {print $4}')
    local available_mb=$((available_kb / 1024))
    
    if [[ $available_mb -lt $required_mb ]]; then
        error_exit "Insufficient disk space. Required: ${required_mb}MB, Available: ${available_mb}MB"
    fi
    
    log_debug "Disk space OK: ${available_mb}MB available (${required_mb}MB required)"
}

# ============================================================================
# Utility Functions
# ============================================================================

# Safe remove with backup
safe_remove() {
    local item="$1"
    
    if [[ ! -e "$item" ]]; then
        return 0
    fi
    
    backup_item "$item"
    
    if [[ "${DRY_RUN:-0}" == "0" ]]; then
        rm -rf "$item"
        log_debug "Removed: $item"
    else
        log_dry "Would remove: $item"
    fi
}

# Safe copy (backs up destination first)
safe_copy() {
    local src="$1"
    local dest="$2"
    
    if [[ ! -e "$src" ]]; then
        error_exit "Source does not exist: $src"
    fi
    
    # Backup destination if it exists
    if [[ -e "$dest" ]]; then
        backup_item "$dest"
    fi
    
    if [[ "${DRY_RUN:-0}" == "0" ]]; then
        local dest_parent
        dest_parent="$(dirname "$dest")"
        mkdir -p "$dest_parent"
        
        if [[ -d "$src" ]]; then
            rm -rf "$dest"
            cp -r "$src" "$dest"
        else
            cp "$src" "$dest"
        fi
        log_debug "Copied: $src -> $dest"
    else
        log_dry "Would copy: $src -> $dest"
    fi
}

# Check if running interactively
is_interactive() {
    [[ -t 0 && -t 1 ]]
}

# Prompt for confirmation (auto-yes in non-interactive mode)
confirm() {
    local prompt="${1:-Continue?}"
    
    if ! is_interactive; then
        log_debug "Non-interactive mode, auto-confirming: $prompt"
        return 0
    fi
    
    read -r -p "$prompt [y/N] " response
    case "$response" in
        [yY][eE][sS]|[yY]) return 0 ;;
        *) return 1 ;;
    esac
}
