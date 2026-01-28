# Agent Guidelines

Personal dev environment manager for Linux (Arch/Ubuntu). Manages dotfiles, shell configs, and software installation using modular bash scripts with profile-based configuration.

## Quick Reference

```bash
# Commands
./dev                   # Show status
./dev init              # First-time setup (select profile)
./dev sync              # Deploy dotfiles
./dev sync --force      # Force sync (overwrite local changes)
./dev install [module]  # Install module(s)
./dev doctor            # Check for issues
./dev diff              # Show differences between repo and deployed
./dev pull <path>       # Pull local changes back to dotfiles
./dev list              # List available modules
./dev show <module>     # Show module details

# Linting (MUST pass before commits)
shellcheck dev lib/*.sh modules/*/install.sh

# Manual verification
./dev --dry-run sync
./dev doctor
```

No automated test suite. Verification: shellcheck + dry-run + doctor.

## Project Structure

```
dev/
├── dev                             # Main CLI (entrypoint)
├── config/
│   ├── packages.conf               # Package definitions by OS
│   └── profiles/{wsl,omarchy}.conf # Profile configurations
├── modules/{name}/                 # Install modules
│   ├── meta                        # DESCRIPTION, DEPENDS, PROFILES
│   └── install.sh                  # module_check(), module_install()
├── dotfiles/{common,wsl,omarchy,{machine},work}/
├── lib/
│   ├── common.sh                   # Logging, validation, safe ops
│   ├── os.sh                       # OS detection, package management
│   ├── config.sh                   # Config loading
│   ├── modules.sh                  # Module discovery/execution
│   └── state.sh                    # State tracking
└── .local/                         # Gitignored local state
    ├── machine.conf                # Machine configuration
    └── state                       # Module install state
```

## Code Style

### Script Headers (REQUIRED)

```bash
#!/usr/bin/env bash
set -euo pipefail
```

Library scripts also source dependencies:
```bash
source "$DEV_ROOT/lib/common.sh"
source "$DEV_ROOT/lib/os.sh"
```

### Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Global variables | `UPPER_CASE` | `DEV_ROOT`, `PROFILE`, `OS` |
| Local variables | `lower_case` | `local module`, `local dest` |
| Internal/private | `_PREFIXED` | `_BACKUP_SESSION_DIR`, `_LOG_LEVELS` |
| Functions | `snake_case` | `log_info`, `module_check` |
| Namespaced funcs | `prefix_action` | `log_*`, `pkg_*`, `module_*`, `state_*`, `sync_*` |

### Variable Usage

```bash
# ALWAYS quote variables
"$var"              # Correct
$var                # WRONG - unquoted

# ALWAYS use [[ ]] for tests
[[ -f "$file" ]]    # Correct
[ -f "$file" ]      # WRONG - POSIX test

# ALWAYS use $() for command substitution
result=$(command)   # Correct
result=`command`    # WRONG - backticks
```

### Control Flow Patterns

```bash
# Short-circuit (preferred for simple conditions)
[[ -z "$VAR" ]] && echo "empty"
command -v tool >/dev/null 2>&1 && echo "found"
[[ -d "$dir" ]] || error_exit "Missing: $dir"

# Error block (for multi-line error handling)
[[ -d "$src" ]] || {
    log_error "Missing directory: $src"
    exit 1
}

# OS-specific branching
case "$OS" in
    arch)   install_packages "neovim" ;;
    ubuntu) curl -LO https://... ;;
    *)      error_exit "Unsupported OS: $OS" ;;
esac
```

### Function Patterns

```bash
# Always declare locals
my_function() {
    local arg1="$1"
    local result
    result=$(some_command)
    echo "$result"
}

# Check command existence
command -v tool >/dev/null 2>&1
```

## Core Library Functions

### Logging (lib/common.sh)
```bash
log_debug "message"    # Only if LOG_LEVEL=DEBUG
log_info "message"     # Standard info
log_warn "message"     # Warnings to stderr
log_error "message"    # Errors to stderr
log_success "message"  # Success with green [OK]
log_dry "message"      # Dry-run preview
```

### Validation (exit on failure)
```bash
require_command git "msg"     # Exits if command missing
require_dir "/path"           # Exits if directory missing
require_file "/path"          # Exits if file missing
error_exit "message" [code]   # Log error and exit
```

### Safe Operations (auto backup)
```bash
safe_copy "$src" "$dest"      # Backup dest, then copy
safe_remove "$path"           # Backup, then remove
```

### Package Management (lib/os.sh)
```bash
OS=$(detect_os)               # Returns: arch|ubuntu|unknown
ENV=$(detect_environment)     # Returns: wsl|native
pkg_install pkg1 pkg2         # Install via pacman/apt
install_packages "category"   # From packages.conf: category_common + category_$OS
```

## Module System

### Module Structure
```
modules/{name}/
├── meta        # Metadata (sourced as bash)
└── install.sh  # Installation script
```

### meta File Format
```bash
DESCRIPTION="Human readable description"
DEPENDS=(core cli-tools)  # Dependencies (installed first)
PROFILES=()               # Empty = all profiles; or (wsl) / (omarchy)
```

### install.sh Requirements
```bash
#!/usr/bin/env bash
set -euo pipefail

# REQUIRED: Check if module is already installed
module_check() {
    command -v tool >/dev/null 2>&1
}

# REQUIRED: Installation logic
module_install() {
    install_packages "category"
    # Additional setup...
}

# OPTIONAL: Update logic
module_update() {
    # Update commands...
}
```

### Module Best Practices
- Use `require_command` for dependencies: `require_command mise "mise required (install cli-tools first)"`
- Use `log_info` for progress messages
- Use `error_exit` for fatal errors
- Download to temp files, clean up after: `local tmp=$(mktemp); curl ... -o "$tmp"; ...; rm -f "$tmp"`

## packages.conf Format

```bash
# Format: category_os=(packages...)
core_common=(git)           # All OSes
core_arch=(base-devel)      # Arch only
core_ubuntu=(build-essential) # Ubuntu only

# Usage: install_packages "core"
# Installs: core_common + core_$OS
```

## Dotfile Layer System

Precedence (later overrides earlier):
1. `common/` - All profiles
2. `wsl/` or `omarchy/` - Profile-specific
3. `{machine}/` - Machine-specific (matches MACHINE_NAME)
4. `windows/` - Windows configs (INCLUDE_WINDOWS=true)
5. `work/` - Work layer (INCLUDE_WORK=true, highest precedence)

## Anti-Patterns (AVOID)

```bash
# DON'T use cd in scripts (breaks on errors)
cd /some/dir && command     # WRONG
command /some/dir/file      # Use absolute paths

# DON'T leave variables unquoted
rm -rf $path                # WRONG - word splitting
rm -rf "$path"              # Correct

# DON'T use [ ] for tests
[ -f "$file" ]              # WRONG
[[ -f "$file" ]]            # Correct

# DON'T hardcode package names in modules
sudo pacman -S neovim       # WRONG
install_packages "neovim"   # Correct - uses packages.conf

# DON'T modify $HOME directly in modules
echo "config" > ~/.zshrc    # WRONG
# Use dotfiles layers instead

# DON'T use backticks
result=`command`            # WRONG
result=$(command)           # Correct
```

## Machine Config (.local/machine.conf)

```bash
PROFILE="wsl"                  # Required: wsl or omarchy
MACHINE_NAME="my-laptop"       # Required: for machine-specific dotfiles
EXTRA_MODULES=(php dotnet)     # Optional: add to profile modules
SKIP_MODULES=()                # Optional: exclude from profile
INCLUDE_WINDOWS=false          # Include Windows desktop configs
INCLUDE_WORK=true              # Include work dotfiles layer
```

## Git Submodules

```bash
git submodule update --init --recursive  # Initialize submodules
```

The `work` dotfiles layer is a private submodule.
