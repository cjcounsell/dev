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

# Omarchy 4 (quattro) is a pacman package and manages OMARCHY_PATH itself
# (/usr/share/omarchy, or a dev checkout via /etc/omarchy.conf) through
# /etc/profile.d/omarchy.sh and the uwsm env.d. Do not re-export the retired
# ~/.local/share/omarchy git-checkout path here — it is not a git checkout
# anymore and breaks `omarchy update`.
export PATH="$HOME/.local/bin:$PATH"
