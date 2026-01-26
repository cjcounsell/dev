# Agent Guidelines

Personal dev environment manager for Linux (Arch/Ubuntu). Manages dotfiles, shell configs, and software installation using modular bash scripts with profile-based configuration.

## Quick Reference

```bash
./dev                   # Show status
./dev init              # First-time setup (select profile)
./dev sync              # Deploy dotfiles
./dev sync --force      # Force sync (overwrite local changes)
./dev install [module]  # Install module(s)
./dev doctor            # Check for issues
./dev diff              # Show differences between repo and deployed
./dev pull <path>       # Pull local changes back to dotfiles
```

## Repository Structure

```
dev/
├── dev                         # Main CLI entry point
├── config/
│   ├── packages.conf           # Package definitions by OS
│   └── profiles/{wsl,omarchy}.conf
├── modules/{name}/             # Install modules
│   ├── meta                    # DESCRIPTION, DEPENDS, PROFILES
│   └── install.sh              # module_check(), module_install()
├── dotfiles/
│   ├── common/                 # All profiles
│   ├── wsl/                    # WSL-specific
│   ├── omarchy/                # Arch desktop
│   ├── {machine}/              # Machine-specific (g14, desktop)
│   └── work/                   # Work layer (submodule)
├── lib/                        # Shared utilities
│   ├── common.sh               # Logging, backup, validation
│   ├── os.sh                   # OS detection, package manager
│   ├── config.sh               # Profile/config loading
│   ├── modules.sh              # Module discovery, deps
│   └── state.sh                # Installation tracking
└── .local/machine.conf         # Local config (gitignored)
```

## Code Style

### Shell Scripts

```bash
#!/usr/bin/env bash
set -euo pipefail

source "$DEV_ROOT/lib/common.sh"
source "$DEV_ROOT/lib/os.sh"
```

**Variables**: `UPPER_CASE` (globals), `lower_case` (locals), `_PREFIXED` (internal)

**Functions**: `snake_case`, namespaced (`log_*`, `pkg_*`, `module_*`, `state_*`)

### Key Library Functions

```bash
# Logging (lib/common.sh)
log_info "message"              # Blue
log_warn "message"              # Yellow, stderr
log_error "message"             # Red, stderr
log_success "message"           # Green

# Validation - exits on failure
require_command git "Git required"
require_dir "/path"
require_file "/path/file"

# Safe operations - auto backup
safe_copy "$src" "$dest"
safe_remove "$path"

# Package management (lib/os.sh)
OS=$(detect_os)                 # arch|ubuntu|unknown
ENV=$(detect_environment)       # wsl|native
pkg_install pkg1 pkg2           # OS-agnostic install
install_packages "category"     # From packages.conf
```

### Conditionals & Error Handling

```bash
[[ -z "$VAR" ]] && echo "empty"
[[ -d "$dir" ]] || mkdir -p "$dir"
command -v nvim >/dev/null 2>&1 && echo "found"

[[ -d "$src" ]] || {
    log_error "Source missing"
    exit 1
}
```

## Module Structure

### meta
```bash
DESCRIPTION="Human readable description"
DEPENDS=(core cli-tools)
PROFILES=()  # Empty = all profiles
```

### install.sh
```bash
#!/usr/bin/env bash

module_check() {
    command -v tool >/dev/null 2>&1
}

module_install() {
    install_packages "category"
}
```

### Common Patterns

```bash
# Version check
module_check() {
    command -v node >/dev/null 2>&1 && \
    node -v 2>/dev/null | grep -q "^v2[4-9]"
}

# OS-specific install
module_install() {
    case "$OS" in
        arch) install_packages "neovim" ;;
        ubuntu)
            curl -LO https://example.com/tool.tar.gz
            sudo tar -C /opt -xzf tool.tar.gz
            ;;
    esac
}
```

## Dotfile Layers

Order (later overrides earlier): `common → profile → machine → windows → work`

| Layer | Purpose |
|-------|---------|
| `common/` | All profiles |
| `wsl/`, `omarchy/` | Profile-specific |
| `{machine}/` | Machine-specific (g14, desktop) |
| `windows/` | Windows configs (INCLUDE_WINDOWS=true) |
| `work/` | Work submodule (INCLUDE_WORK=true) |

## Lua (Neovim)

- **Formatting**: 2 spaces indent, 120 column width (StyLua)
- **Style**: `vim.opt.*`, `vim.g.*`, `vim.schedule(function() end)`

## Zsh

```zsh
[[ -f "$path" ]] && source "$path"
command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"
```

## Git Submodules

```bash
git submodule update --init --recursive
```

- `dotfiles/common/.config/nvim` - Neovim config
- `dotfiles/work/` - Work environment (private)

## Machine Config (.local/machine.conf)

```bash
PROFILE="wsl"
MACHINE_NAME="my-laptop"
EXTRA_MODULES=(php dotnet)
SKIP_MODULES=()
INCLUDE_WINDOWS=false
INCLUDE_WORK=true
```
