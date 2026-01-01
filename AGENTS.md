# Agent Guidelines

This repository contains personal development environment configuration and setup scripts
for Linux systems (Arch and Ubuntu). It manages dotfiles, shell configs, and software
installation across machines using a modular, scriptable approach.

## Repository Structure

```
dev/
├── env/                    # Configuration files to deploy to $HOME
│   ├── .config/            # XDG config files (nvim, tmux, kitty, hyprland, etc.)
│   ├── .local/scripts/     # Custom shell scripts added to PATH
│   └── .*                   # Dotfiles (.aliases, .zshrc, .zshenv, .zprofile)
├── runs/                   # Numbered executable setup scripts (0-dev, 1-libs, etc.)
├── utils/                  # Shared utility scripts (os-detect.sh)
├── work/                   # Work-specific configs (git submodule, private)
├── init                    # Initialize git submodules
├── dev-env                 # Deploy configs to system
└── run                     # Execute setup scripts
```

## Build/Test Commands

### Setup and Deployment
```bash
./init                      # Initialize git submodules (nvim config, work repo)
./dev-env                   # Deploy all configs from env/ to system (requires DEV_ENV)
./run [grep_pattern]        # Execute matching scripts in runs/ directory
./run --dry [grep_pattern]  # Preview what would run without executing
```

### Running Specific Setup Scripts
```bash
./run 0-dev      # Install base dev tools (git, paru/apt, bitwarden-cli)
./run 1-libs     # Install CLI utilities (bat, eza, fzf, ripgrep, lazygit, etc.)
./run 2-ssh      # Configure SSH keys from Bitwarden
./run 3-zsh      # Install zsh, oh-my-zsh, starship prompt
./run 4-neovim   # Install neovim
./run 5-tmux     # Install tmux
./run 6-node     # Install Node.js via mise
./run 7-php      # Install PHP via Herd
./run 8-dotnet   # Install .NET SDK via mise
```

### Required Environment Variables
```bash
export DEV_ENV="/path/to/this/repo"   # Required for dev-env and run scripts
export WORK_ENV="/path/to/work/repo"  # Required for work-env script
export XDG_CONFIG_HOME="$HOME/.config" # Used by config scripts
```

## Code Style Guidelines

### Shell Scripts

#### Shebang and Strict Mode
- Always use `#!/usr/bin/env bash` for bash scripts
- Always use `#!/usr/bin/env zsh` for zsh scripts
- Use `set -euo pipefail` at the start of setup scripts for strict error handling:
  - `-e`: Exit on error
  - `-u`: Error on undefined variables
  - `-o pipefail`: Fail on pipe errors

#### Conditionals and Tests
```bash
# CORRECT: Use double brackets
[[ -z "$VAR" ]] && echo "empty"
[[ -d "$dir" ]] || mkdir -p "$dir"
[[ -f "$file" ]] && source "$file"

# INCORRECT: Single brackets
[ -z "$VAR" ]  # Don't use this
```

#### Command Existence Checks
```bash
# CORRECT: Redirect both stdout and stderr
command -v nvim >/dev/null 2>&1 && echo "found"
if command -v mise >/dev/null 2>&1; then
    mise use -g node@24
fi

# INCORRECT: Missing redirects
command -v nvim && echo "found"
```

#### Error Handling Patterns
```bash
# Use inline error handling with || and {}
[[ -d "$src" ]] || {
    log "Source dir $src missing"
    exit 1
}

# Or use if statements for complex logic
if ! git clone "$url" "$dest"; then
    echo "Clone failed" >&2
    exit 1
fi
```

#### Function Definitions
```bash
# Define helper functions at script top
log() {
    if [[ "$dry_run" == "1" ]]; then
        echo "[DRY_RUN]: $1"
    else
        echo "$1"
    fi
}

# Use local variables in functions
update_files() {
    local src="$1" dest="$2"
    # ...
}
```

#### Path and Variable Handling
```bash
# CORRECT: Quote all variables, especially paths
pushd "$src" >/dev/null
cp -r "./$c" "$dest"

# CORRECT: Use absolute paths or explicit relative paths
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# CORRECT: Handle array creation safely
mapfile -t scripts < <(find "$runs_dir" -type f -executable)
for s in "${scripts[@]}"; do
    # ...
done
```

#### OS Detection Pattern
```bash
source ./utils/os-detect.sh
os=$(detect_os)

case "$os" in
arch)
    paru -S --noconfirm --needed package_name
    ;;
ubuntu)
    sudo apt-get update
    sudo apt-get install -y package_name
    ;;
esac
```

### Lua (Neovim Config)

#### Formatting (stylua.toml)
- Indent: 2 spaces (not tabs)
- Column width: 120 characters
- Use StyLua for formatting

#### Style
```lua
-- Use vim.opt for options
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4

-- Use vim.g for global variables
vim.g.autoformat = false

-- Use schedule for async operations
vim.schedule(function()
    -- ...
end)

-- Add filetypes with vim.filetype.add
vim.filetype.add({
    extension = { Tiltfile = 'starlark' },
    filename = { ["Tiltfile"] = "starlark" },
})
```

### Zsh Configuration

#### Plugin Management
```zsh
# Define plugins before sourcing oh-my-zsh
plugins=(git mise)
[[ -f "$ZSH/oh-my-zsh.sh" ]] && source "$ZSH/oh-my-zsh.sh"
```

#### Conditional Sourcing
```zsh
# Use arrays for multiple config files
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
# Check before initializing
command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init --cmd cd zsh)"
```

## Git Submodules

This repo uses submodules for:
- `env/.config/nvim` - Neovim configuration (separate repo)
- `work/` - Work-specific environment (private repo)

After cloning, run `./init` to initialize and update submodules.

## Adding New Setup Scripts

1. Create executable file in `runs/` with numeric prefix: `runs/9-newscript`
2. Make it executable: `chmod +x runs/9-newscript`
3. Follow the standard template:

```bash
#!/usr/bin/env bash

set -euo pipefail

source ./utils/os-detect.sh
os=$(detect_os)

case "$os" in
arch)
    paru -S --noconfirm --needed package_name
    ;;
ubuntu)
    sudo apt-get update
    sudo apt-get install -y package_name
    ;;
esac

# Common setup for both distros
# ...
```

## Adding New Configs

1. Place config files in appropriate location under `env/`:
   - `env/.config/appname/` for XDG configs
   - `env/.local/scripts/` for custom scripts
   - `env/.dotfile` for home directory dotfiles
2. Update `dev-env` if adding new dotfile locations
3. Run `./dev-env` to deploy
