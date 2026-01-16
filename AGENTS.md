# Agent Guidelines

Personal dev environment manager for Linux (Arch/Ubuntu). Manages dotfiles, shell configs,
and software installation using modular bash scripts with profile-based configuration.

## Repository Structure

```
dev/
├── dev                         # Main CLI entry point
├── config/
│   ├── packages.conf           # Package definitions by OS
│   └── profiles/
│       ├── wsl.conf            # WSL2 profile
│       └── omarchy.conf        # Arch desktop profile
├── modules/                    # Install modules
│   ├── core/                   # Base dev tools
│   ├── shell/                  # Zsh, Oh-My-Zsh, Starship
│   ├── cli-tools/              # fzf, ripgrep, bat, etc.
│   ├── ssh/                    # SSH keys from Bitwarden
│   ├── neovim/                 # Neovim editor
│   ├── tmux/                   # Terminal multiplexer
│   ├── node/                   # Node.js via mise
│   ├── php/                    # PHP via Herd
│   ├── dotnet/                 # .NET via mise
│   ├── desktop/                # Hyprland (omarchy only)
│   └── secrets/                # Bitwarden CLI + secrets
├── dotfiles/
│   ├── common/                 # All profiles
│   │   ├── .config/
│   │   ├── .local/scripts/
│   │   └── .*                  # Shell dotfiles
│   ├── wsl/                    # WSL profile-specific Linux configs
│   │   └── .config/
│   ├── windows/                # Windows desktop configs (optional)
│   │   └── .config/
│   │       ├── yasb/           # Windows taskbar
│   │       └── glazewm/        # Windows tiling WM
│   ├── omarchy/                # Desktop-specific (all omarchy machines)
│   │   └── .config/hypr/
│   ├── g14/                    # Machine-specific (laptop)
│   │   └── .config/uwsm/
│   ├── desktop/                # Machine-specific (desktop)
│   └── work/                   # Work configs (submodule)
├── lib/                        # Shared utilities
│   ├── common.sh               # Logging, backup, validation
│   ├── os.sh                   # OS detection, package manager
│   ├── config.sh               # Profile/config loading
│   ├── modules.sh              # Module discovery, deps
│   └── state.sh                # Installation tracking
└── .local/                     # Gitignored local state
    ├── machine.conf            # Machine-specific config
    └── state                   # What's installed
```

## CLI Commands

```bash
./dev                          # Show status
./dev init                     # First-time setup (select profile)
./dev sync                     # Deploy dotfiles
./dev install [module...]      # Install module(s)
./dev status                   # Show installation status
./dev list                     # List available modules
./dev update                   # Update system packages
./dev doctor                   # Check for issues
```

## Code Style Guidelines

### Shell Scripts

#### Shebang and Strict Mode
```bash
#!/usr/bin/env bash
set -euo pipefail
```

#### Conditionals
```bash
[[ -z "$VAR" ]] && echo "empty"
[[ -d "$dir" ]] || mkdir -p "$dir"
```

#### Command Checks
```bash
command -v nvim >/dev/null 2>&1 && echo "found"
```

#### Error Handling
```bash
[[ -d "$src" ]] || {
    log_error "Source missing"
    exit 1
}
```

#### Using Library Functions
```bash
source "$DEV_ROOT/lib/common.sh"
source "$DEV_ROOT/lib/os.sh"

log_info "Installing packages"
log_error "Failed"
log_success "Done"

require_command git
require_dir "$path"
safe_copy "$src" "$dest"

pkg_install package1 package2
install_packages "cli"
```

### Lua (Neovim Config)

#### Formatting (stylua.toml)
- Indent: 2 spaces (not tabs)
- Column width: 120 characters
- Use StyLua for formatting

#### Style
```lua
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.g.autoformat = false

vim.schedule(function()
    -- ...
end)

vim.filetype.add({
    extension = { Tiltfile = 'starlark' },
    filename = { ["Tiltfile"] = "starlark" },
})
```

### Zsh Configuration

#### Plugin Management
```zsh
plugins=(git mise)
[[ -f "$ZSH/oh-my-zsh.sh" ]] && source "$ZSH/oh-my-zsh.sh"
```

#### Conditional Sourcing
```zsh
local configs=(
    "$HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh"
    "$HOME/.aliases"
)
for config in "${configs[@]}"; do
    [[ -f "$config" ]] && source "$config"
done
```

#### Tool Initialization
```zsh
command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init --cmd cd zsh)"
```

## Module Structure

Each module has:
- `meta` - Metadata (DESCRIPTION, DEPENDS, PROFILES)
- `install.sh` - Installation script

```bash
# modules/example/meta
DESCRIPTION="Example module"
DEPENDS=(core cli-tools)
PROFILES=()  # Empty = all profiles

# modules/example/install.sh
#!/usr/bin/env bash

module_check() {
    command -v example >/dev/null 2>&1
}

module_install() {
    install_packages "example"
}

module_update() {
    # Optional
}
```

## Adding New Modules

1. Create `modules/newmodule/meta`:
```bash
DESCRIPTION="What it does"
DEPENDS=(core)
PROFILES=()
```

2. Create `modules/newmodule/install.sh`:
```bash
#!/usr/bin/env bash

module_check() {
    command -v tool >/dev/null 2>&1
}

module_install() {
    install_packages "category"
}
```

3. Add packages to `config/packages.conf` if needed

4. Add to profile's `PROFILE_MODULES` or `OPTIONAL_MODULES`

## Adding New Dotfiles

1. Place files in appropriate layer:
   - `dotfiles/common/` - All profiles
   - `dotfiles/wsl/` - WSL profile only (WSL-specific Linux configs)
   - `dotfiles/windows/` - Windows desktop configs (optional, enable with INCLUDE_WINDOWS=true)
   - `dotfiles/omarchy/` - All omarchy machines (shared desktop config)
   - `dotfiles/<machine>/` - Machine-specific (e.g., `g14/`, `desktop/`)
   - `dotfiles/work/` - Work layer (submodule)

2. Run `./dev sync` to deploy

Layer order: `common → profile → machine → windows → work` (later layers override earlier)

## Git Submodules

This repo uses submodules for:
- `dotfiles/common/.config/nvim` - Neovim configuration
- `dotfiles/work/` - Work-specific environment (private)

After cloning, run `git submodule update --init --recursive`

## Machine Configuration

Created by `./dev init`, stored in `.local/machine.conf`:

```bash
PROFILE="wsl"
MACHINE_NAME="my-laptop"
EXTRA_MODULES=(php)
SKIP_MODULES=()
INCLUDE_WINDOWS=true
INCLUDE_WORK=true
```
