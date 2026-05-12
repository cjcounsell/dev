#!/usr/bin/env bash
# Common utilities for dev environment scripts
# Source this file: source "$DEV_ROOT/lib/common.sh"

# ============================================================================
# Configuration
# ============================================================================
BACKUP_DIR="${BACKUP_DIR:-$HOME/.config-backups}"
LOG_LEVEL="${LOG_LEVEL:-INFO}" # DEBUG, INFO, WARN, ERROR
DRY_RUN="${DRY_RUN:-0}"

# Color codes (disabled if not a terminal)
if [[ -t 1 ]]; then
	_RED='\033[0;31m'
	_GREEN='\033[0;32m'
	_YELLOW='\033[0;33m'
	_BLUE='\033[0;34m'
	_GRAY='\033[0;90m'
	_BOLD='\033[1m'
	_NC='\033[0m'
else
	_RED='' _GREEN='' _YELLOW='' _BLUE='' _GRAY='' _BOLD='' _NC=''
fi

# ============================================================================
# Logging Functions
# ============================================================================
declare -A _LOG_LEVELS=([DEBUG]=0 [INFO]=1 [WARN]=2 [ERROR]=3)

_should_log() {
	local level="$1"
	local current=${_LOG_LEVELS[${LOG_LEVEL:-INFO}]:-1}
	local target=${_LOG_LEVELS[$level]:-1}
	[[ $target -ge $current ]]
}

log_debug() {
	_should_log "DEBUG" && echo -e "${_GRAY}[DEBUG]${_NC} $*" || true
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
	echo -e "${_YELLOW}[DRY]${_NC} $*"
}

# ============================================================================
# Error Handling
# ============================================================================
error_exit() {
	log_error "$1"
	exit "${2:-1}"
}

# ============================================================================
# Validation Functions
# ============================================================================
require_command() {
	local cmd="$1"
	local msg="${2:-Required command not found: $cmd}"
	if ! command -v "$cmd" >/dev/null 2>&1; then
		error_exit "$msg"
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
	local check_path="$path"

	while [[ ! -e "$check_path" && "$check_path" != "/" ]]; do
		check_path="$(dirname "$check_path")"
	done

	if [[ ! -w "$check_path" ]]; then
		error_exit "No write permission: $path"
	fi
}

# ============================================================================
# Safe Operations
# ============================================================================
safe_remove() {
	local item="$1"

	[[ ! -e "$item" ]] && return 0

	if [[ "${DRY_RUN:-0}" == "0" ]]; then
		rm -rf "$item"
		log_debug "Removed: $item"
	else
		log_dry "Would remove: $item"
	fi
}

safe_copy() {
	local src="$1"
	local dest="$2"

	[[ ! -e "$src" ]] && error_exit "Source does not exist: $src"

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

# ============================================================================
# Interactive Helpers
# ============================================================================
is_interactive() {
	[[ -t 0 && -t 1 ]]
}

confirm() {
	local prompt="${1:-Continue?}"

	if ! is_interactive; then
		return 0
	fi

	read -r -p "$prompt [y/N] " response
	case "$response" in
	[yY][eE][sS] | [yY]) return 0 ;;
	*) return 1 ;;
	esac
}

prompt_input() {
	local prompt="$1"
	local default="${2:-}"
	local result

	if [[ -n "$default" ]]; then
		read -r -p "$prompt [$default]: " result
		echo "${result:-$default}"
	else
		read -r -p "$prompt: " result
		echo "$result"
	fi
}

bw_ensure_session() {
	require_command bw "Bitwarden CLI required"
	require_command jq "jq required"

	if [[ -n "${BW_SESSION:-}" ]]; then
		return 0
	fi

	bw login --check 2>/dev/null || {
		log_info "Logging into Bitwarden"
		bw login
	}

	BW_SESSION=$(bw unlock --raw) || error_exit "Failed to unlock Bitwarden vault"
	export BW_SESSION
}

# ============================================================================
# Dotfile Layer Assembly
# ============================================================================

# Build the complete dotfile layers array
# Outputs layer names to stdout, one per line
# Caller can capture with: mapfile -t layers < <(build_dotfile_layers)
#
# Layer precedence (lowest to highest):
# 1. Profile dotfiles (from PROFILE_DOTFILES array)
# 2. Machine-specific (if MACHINE_NAME set and dir exists)
# 3. Windows layer (if INCLUDE_WINDOWS=true)
# 4. Work layer (if INCLUDE_WORK=true) - highest precedence
build_dotfile_layers() {
	local layers=("${PROFILE_DOTFILES[@]}")

	# Add machine-specific layer if it exists
	if [[ -n "${MACHINE_NAME:-}" ]] && [[ -d "$DEV_ROOT/dotfiles/$MACHINE_NAME" ]]; then
		layers+=("$MACHINE_NAME")
	fi

	# Add windows layer if enabled (before work)
	if [[ "${INCLUDE_WINDOWS:-false}" == "true" ]]; then
		layers+=(windows)
	fi

	# Add work layer last (highest precedence)
	if [[ "${INCLUDE_WORK:-false}" == "true" ]]; then
		layers+=(work)
	fi

	printf '%s\n' "${layers[@]}"
}

# ============================================================================
# Network Functions
# ============================================================================

# Curl wrapper with timeouts and error handling
# Usage: safe_curl [curl-args...] URL
safe_curl() {
	local url="${!#}" # Last argument is URL

	if ! curl --connect-timeout 30 --max-time 300 --fail --silent --show-error "$@"; then
		local exit_code=$?
		log_error "Download failed: $url (exit code: $exit_code)"
		return $exit_code
	fi
}

# Wget wrapper with timeouts and error handling
# Usage: safe_wget [wget-args...] URL
safe_wget() {
	local url="${!#}" # Last argument is URL

	if ! wget --timeout=30 --tries=1 "$@"; then
		local exit_code=$?
		log_error "Download failed: $url (exit code: $exit_code)"
		return $exit_code
	fi
}
