#!/usr/bin/env bash
# State tracking for installed modules and sync status
# Uses simple key=value format (no external dependencies)

STATE_FILE="$DEV_ROOT/.local/state"

trap 'rm -f "$STATE_FILE".$$' EXIT

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
	local tmp_file="$STATE_FILE.$$"

	# Create temp file without the key, add new entry
	{
		grep -v "^${key}=" "$STATE_FILE" 2>/dev/null || true
		echo "${key}=${value}"
	} >"$tmp_file"

	# Sync to disk and atomically replace
	sync "$tmp_file" 2>/dev/null || true
	mv "$tmp_file" "$STATE_FILE" || {
		rm -f "$tmp_file"
		return 1
	}
}

state_remove() {
	local key="$1"
	local tmp_file="$STATE_FILE.$$"

	grep -v "^${key}=" "$STATE_FILE" >"$tmp_file" 2>/dev/null || true

	sync "$tmp_file" 2>/dev/null || true
	mv "$tmp_file" "$STATE_FILE" || {
		rm -f "$tmp_file"
		return 1
	}
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
