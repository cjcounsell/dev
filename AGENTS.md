# Agent Guidelines

Personal dev environment manager for Linux (Arch/Ubuntu). Manages dotfiles, shell configs, and software installation using modular bash scripts with profile-based configuration.

## Build / Lint / Test

```bash
# Lint (MUST pass before commits)
shellcheck dev lib/*.sh modules/*/install.sh

# Lint single file
shellcheck modules/node/install.sh

# Manual verification (no automated test suite)
./dev --dry-run sync
./dev doctor
```

No unit tests. Verification = shellcheck + dry-run + doctor.

## Commands

```bash
./dev                   # Show status
./dev init              # First-time setup (select profile)
./dev sync [PATH...]    # Deploy dotfiles (all or specific files)
./dev sync --force      # Overwrite local changes
./dev diff [PATH]       # Show repo vs deployed differences
./dev pull <path>       # Pull local changes back to dotfiles
./dev install [module]  # Install module(s) with dependency resolution
./dev list              # List available modules
./dev show <module>     # Show module details
./dev update            # Update system packages
./dev doctor            # Diagnostics
```

Global flags: `--dry-run|-n`, `--force|-f`, `--yes|-y`, `--verbose|-v`

## Project Structure

```
dev                       # Main CLI entrypoint
config/
  packages.conf           # Package arrays by OS: {category}_{common|arch|ubuntu}
  profiles/{wsl,omarchy}.conf  # PROFILE_MODULES, PROFILE_DOTFILES, optional *_post_sync hook
modules/{name}/
  meta                    # DESCRIPTION, DEPENDS=(), PROFILES=()
  install.sh              # module_check(), module_install(), optional module_update()
dotfiles/{common,wsl,omarchy,{machine},windows,work}/
lib/
  common.sh               # Logging, validation, safe ops, backup, diff, dotfile layers, network
  os.sh                   # OS detection, pkg_install, pkg_update, install_packages
  config.sh               # safe_source, load_machine_config, load_profile, load_packages
  modules.sh              # Module discovery, metadata, dependency resolution, execution
  state.sh                # Key=value state file for module/sync tracking
.local/                   # Gitignored: machine.conf, state
```

## Code Style

### Headers (REQUIRED for all scripts)

```bash
#!/usr/bin/env bash
set -euo pipefail
```

Library files also source dependencies: `source "$DEV_ROOT/lib/common.sh"`

### Naming

| Type | Convention | Example |
|------|-----------|---------|
| Globals | `UPPER_CASE` | `DEV_ROOT`, `PROFILE`, `OS` |
| Locals | `lower_case` with `local` | `local module`, `local dest` |
| Private/internal | `_PREFIXED` | `_BACKUP_SESSION_DIR`, `_LOG_LEVELS` |
| Functions | `snake_case`, namespaced | `log_info`, `pkg_install`, `module_check`, `state_get` |

### Variables and Tests

```bash
"$var"                    # ALWAYS quote — never bare $var
[[ -f "$file" ]]          # ALWAYS [[ ]] — never [ ]
result=$(command)         # ALWAYS $() — never backticks
local var="$1"            # ALWAYS declare locals
```

### Control Flow

```bash
# Short-circuit for simple conditions (preferred)
[[ -z "$VAR" ]] && echo "empty"
command -v tool >/dev/null 2>&1 || error_exit "Missing: tool"

# Multi-line error block
[[ -d "$src" ]] || {
    log_error "Missing: $src"
    exit 1
}

# OS branching
case "$OS" in
    arch)   pkg_install neovim ;;
    ubuntu) curl -LO https://... ;;
    *)      error_exit "Unsupported: $OS" ;;
esac
```

### Error Handling

- Use `error_exit "message"` for fatal errors (logs + exits)
- Use `require_command`, `require_dir`, `require_file` for precondition checks
- Download to temp files, clean up after: `local tmp=$(mktemp); curl ... -o "$tmp"; ...; rm -f "$tmp"`
- Wrap network calls with `safe_curl` / `safe_wget` (timeout + error handling built in)

## Key Library Functions

**Logging**: `log_debug`, `log_info`, `log_warn`, `log_error`, `log_success`, `log_dry`
**Validation**: `require_command`, `require_dir`, `require_file`, `require_writable`
**Safe ops**: `safe_copy`, `safe_remove` (auto-backup before destructive ops)
**Config**: `safe_source` (path-validated sourcing), `load_machine_config`, `load_profile`, `load_packages`
**Packages**: `pkg_install pkg1 pkg2`, `install_packages "category"` (reads packages.conf arrays)
**OS**: `detect_os` (arch|ubuntu|unknown), `detect_environment` (wsl|native)
**State**: `state_get`, `state_set`, `module_is_installed`, `module_mark_installed`
**Network**: `safe_curl [args] URL`, `safe_wget [args] URL`
**Secrets**: `bw_ensure_session` (ensures Bitwarden CLI is logged in and unlocked)

## Module System

### Writing a Module

Create `modules/{name}/meta`:
```bash
DESCRIPTION="Human readable description"
DEPENDS=(core cli-tools)    # Resolved before install
PROFILES=()                 # Empty = all; or (wsl) / (omarchy)
```

Create `modules/{name}/install.sh`:
```bash
#!/usr/bin/env bash
set -euo pipefail

module_check() {
    command -v tool >/dev/null 2>&1
}

module_install() {
    require_command mise "mise required (install cli-tools first)"
    install_packages "category"
}

module_update() {  # Optional
    mise upgrade tool
}
```

**Execution context**: Modules run in a subshell with common.sh, os.sh, config.sh, and packages.conf pre-loaded. `$OS`, `$ENV`, `$DEV_ROOT`, `$DRY_RUN` are available.

### packages.conf Format

```bash
category_common=(pkg1 pkg2)    # All OSes
category_arch=(arch-pkg)       # Arch only
category_ubuntu=(ubuntu-pkg)   # Ubuntu only
# install_packages "category" installs category_common + category_$OS
```

## Dotfile Layer System

Precedence (later overrides earlier):
1. `common/` — All profiles
2. `wsl/` or `omarchy/` — Profile-specific (from PROFILE_DOTFILES)
3. `{machine}/` — Machine-specific (matches MACHINE_NAME from .local/machine.conf)
4. `windows/` — Windows configs (INCLUDE_WINDOWS=true)
5. `work/` — Private submodule, highest precedence (INCLUDE_WORK=true)

Profile configs can define a `{profile}_post_sync()` hook (e.g., `omarchy_post_sync` reloads Hyprland).

## Anti-Patterns

```bash
cd /some/dir && command     # WRONG — use absolute paths
rm -rf $path                # WRONG — always quote: "$path"
[ -f "$file" ]              # WRONG — use [[ ]]
result=`command`            # WRONG — use $()
sudo pacman -S neovim       # WRONG — use install_packages "category"
echo "x" > ~/.zshrc         # WRONG — use dotfiles layers, not direct $HOME writes
```

## Git

```bash
git submodule update --init --recursive  # Required: work layer is a private submodule
```
