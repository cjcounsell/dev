# Core environment variables

export EDITOR="nvim"
export GIT_EDITOR="$EDITOR"
export XDG_CONFIG_HOME="$HOME/.config"
export ZSH="$HOME/.oh-my-zsh"
export DOTFILES="$HOME/.dotfiles"

# Tool-specific paths
export BUN_INSTALL="$HOME/.bun"
export DOTNET_ROOT="$HOME/.dotnet"
export PNPM_HOME="$HOME/.local/share/pnpm"
export STARSHIP_CONFIG="$HOME/.config/starship.toml"
export PHP_INI_SCAN_DIR="$HOME/.config/herd-lite/bin:$PHP_INI_SCAN_DIR"

# Project directories for tmux-sessionizer
# ~/work/mexp included so sessionizer finds worktrees as top-level dirs
export CODE_DIRS="$HOME:$HOME/personal:$HOME/work:$HOME/work/mexp:$HOME/vaults"

# Deno environment
[[ -f "$HOME/.deno/env" ]] && source "$HOME/.deno/env"

# WezTerm integration
export SNACKS_WEZTERM=true

# Editor used by CLI
export SUDO_EDITOR="$EDITOR"
export BAT_THEME=ansi

# Duplicated from .config/uwsm/env so SSH works too
export OMARCHY_PATH=$HOME/.local/share/omarchy
export PATH=$OMARCHY_PATH/bin:$PATH:$HOME/.local/bin
