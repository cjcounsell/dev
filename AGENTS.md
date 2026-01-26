# Agent Guidelines

Personal dev environment manager for Linux (Arch/Ubuntu). Manages dotfiles, shell configs, and software installation using modular bash scripts with profile-based configuration.

## Commands

```bash
./dev                   # Show status
./dev init              # First-time setup (select profile)
./dev sync              # Deploy dotfiles
./dev sync --force      # Force sync (overwrite local changes)
./dev install [module]  # Install module(s)
./dev doctor            # Check for issues
./dev diff              # Show differences between repo and deployed
./dev pull <path>       # Pull local changes back to dotfiles
./dev list              # List available modules
```

## Linting

```bash
shellcheck dev lib/*.sh modules/*/install.sh  # Lint all scripts
```

No automated tests. Manual verification: `./dev --dry-run sync` and `./dev doctor`.

## Structure

```
dev/
├── dev                         # Main CLI (~936 lines)
├── config/
│   ├── packages.conf           # Package definitions by OS
│   └── profiles/{wsl,omarchy}.conf
├── modules/{name}/             # Install modules
│   ├── meta                    # DESCRIPTION, DEPENDS, PROFILES
│   └── install.sh              # module_check(), module_install()
├── dotfiles/{common,wsl,omarchy,{machine},work}/
├── lib/{common,os,config,modules,state}.sh
└── .local/machine.conf         # Local config (gitignored)
```

## Code Style

Every script starts with:
```bash
#!/usr/bin/env bash
set -euo pipefail
source "$DEV_ROOT/lib/common.sh"
source "$DEV_ROOT/lib/os.sh"
```

**Variables**: `UPPER_CASE` (globals), `lower_case` (locals), `_PREFIXED` (internal)

**Functions**: `snake_case`, namespaced (`log_*`, `pkg_*`, `module_*`, `state_*`)

### Key Functions

```bash
# Logging
log_info "message"    log_warn "message"    log_error "message"    log_success "message"

# Validation (exit on failure)
require_command git "msg"    require_dir "/path"    require_file "/path"

# Safe ops (auto backup)
safe_copy "$src" "$dest"    safe_remove "$path"

# Package mgmt
OS=$(detect_os)             # arch|ubuntu|unknown
install_packages "category" # From packages.conf: category_common + category_$OS
```

### Patterns

```bash
# Short-circuit
[[ -z "$VAR" ]] && echo "empty"
command -v nvim >/dev/null 2>&1 && echo "found"

# Error block
[[ -d "$src" ]] || { log_error "Missing"; exit 1; }

# OS-specific
case "$OS" in
    arch) install_packages "neovim" ;;
    ubuntu) curl -LO https://... ;;
esac
```

## Modules

### meta file
```bash
DESCRIPTION="Human readable description"
DEPENDS=(core cli-tools)  # Installed first
PROFILES=()               # Empty = all profiles
```

### install.sh
```bash
#!/usr/bin/env bash

module_check() { command -v tool >/dev/null 2>&1; }

module_install() {
    install_packages "category"
}
```

## Dotfile Layers

Precedence (later overrides): `common → profile → machine → windows → work`

- `common/` - All profiles
- `wsl/`, `omarchy/` - Profile-specific
- `{machine}/` - Machine-specific (g14, desktop)
- `windows/` - Win configs (INCLUDE_WINDOWS=true)
- `work/` - Work submodule (INCLUDE_WORK=true)

## packages.conf

```bash
core_common=(git)
core_arch=(base-devel)
core_ubuntu=(build-essential)
```

## Anti-Patterns

- **Don't** use `cd` in scripts (use absolute paths or subshells)
- **Don't** use unquoted variables: `"$var"` not `$var`
- **Don't** use `[ ]` for tests: use `[[ ]]`
- **Don't** use backticks: use `$(command)`
- **Don't** modify `$HOME` directly in modules; use dotfiles layers
- **Don't** hardcode package names; use packages.conf

## Git Submodules

```bash
git submodule update --init --recursive
```

## Machine Config (.local/machine.conf)

```bash
PROFILE="wsl"
MACHINE_NAME="my-laptop"
EXTRA_MODULES=(php dotnet)
SKIP_MODULES=()
INCLUDE_WINDOWS=false
INCLUDE_WORK=true
```
