#!/usr/bin/env bash
# Module discovery and execution

# ============================================================================
# Module Discovery
# ============================================================================

list_modules() {
    find "$DEV_ROOT/modules" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; 2>/dev/null | sort
}

module_exists() {
    local module="$1"
    [[ -d "$DEV_ROOT/modules/$module" ]]
}

# ============================================================================
# Module Metadata
# ============================================================================

load_module_meta() {
    local module="$1"
    local meta_file="$DEV_ROOT/modules/$module/meta"
    
    # Reset defaults
    DESCRIPTION=""
    DEPENDS=()
    PROFILES=()
    
    if [[ -f "$meta_file" ]]; then
        source "$meta_file"
    fi
}

module_applies_to_profile() {
    local module="$1"
    local profile="${2:-$PROFILE}"
    
    load_module_meta "$module"
    
    # If no profiles specified, applies to all
    [[ ${#PROFILES[@]} -eq 0 ]] && return 0
    
    for p in "${PROFILES[@]}"; do
        [[ "$p" == "$profile" ]] && return 0
    done
    return 1
}

# ============================================================================
# Dependency Resolution
# ============================================================================

resolve_dependencies() {
    local module="$1"
    local -a resolved=()
    local -a visiting=()
    
    _resolve_recursive() {
        local m="$1"
        
        # Check for circular dependency
        for v in "${visiting[@]}"; do
            if [[ "$v" == "$m" ]]; then
                error_exit "Circular dependency detected: $m"
            fi
        done
        
        # Check if already resolved
        for r in "${resolved[@]}"; do
            [[ "$r" == "$m" ]] && return 0
        done
        
        visiting+=("$m")
        
        load_module_meta "$m"
        for dep in "${DEPENDS[@]}"; do
            if ! module_exists "$dep"; then
                error_exit "Module '$m' depends on unknown module: $dep"
            fi
            _resolve_recursive "$dep"
        done
        
        local new_visiting=()
        for v in "${visiting[@]}"; do
            [[ "$v" != "$m" ]] && new_visiting+=("$v")
        done
        visiting=("${new_visiting[@]}")
        
        resolved+=("$m")
    }
    
    _resolve_recursive "$module"
    echo "${resolved[@]}"
}

# ============================================================================
# Module Execution
# ============================================================================

run_module() {
    local module="$1"
    local action="${2:-install}"
    local install_script="$DEV_ROOT/modules/$module/install.sh"
    
    if [[ ! -f "$install_script" ]]; then
        error_exit "Module install script not found: $module"
    fi
    
    (
        source "$DEV_ROOT/lib/common.sh"
        source "$DEV_ROOT/lib/os.sh"
        source "$DEV_ROOT/lib/config.sh"
        load_packages 2>/dev/null || true
        
        source "$install_script"
        
        case "$action" in
            check)
                if declare -f module_check >/dev/null; then
                    module_check
                else
                    exit 1
                fi
                ;;
            install)
                if declare -f module_install >/dev/null; then
                    module_install
                else
                    error_exit "Module missing module_install function: $module"
                fi
                ;;
            update)
                if declare -f module_update >/dev/null; then
                    module_update
                else
                    log_debug "Module has no update function: $module"
                fi
                ;;
        esac
    )
}
