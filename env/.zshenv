#!/usr/bin/env zsh

# Environment variables
export EDITOR="nvim"
export XDG_CONFIG_HOME="$HOME/.config"
export ZSH="$HOME/.oh-my-zsh"
export BUN_INSTALL="$HOME/.bun"
export STARSHIP_CONFIG="$HOME/.config/starship.toml"
export GIT_EDITOR="$EDITOR"
export DOTFILES="$HOME/.dotfiles"
export DOTNET_ROOT="$HOME/.dotnet"
export PNPM_HOME="$HOME/.local/share/pnpm"
export CODE_DIRS="$HOME:$HOME/personal:$HOME/work:$HOME/vaults"
export PHP_INI_SCAN_DIR="$HOME/.config/herd-lite/bin:$PHP_INI_SCAN_DIR"

# Bitwarden item IDs for setup scripts
export BW_SSH_KEY_ID="9310c75b-a4c1-451c-8905-b27e01846f15"
export BW_INTELEPHENSE_ID="421bb870-b923-44e6-b2fe-b38c0009bfe3"
export BW_GH_MCP_TOKEN_ID="ac4e13d5-1494-45b5-8d3a-b3c50117d9be"

# Ensure unique PATH entries
typeset -U PATH path
path+=("$HOME/.config/herd-lite/bin")
path+=("$BUN_INSTALL/bin")
path+=("$HOME/.config/composer/vendor/bin")
path+=("$HOME/.local/bin")
path+=("$HOME/.local/scripts")
path+=("/usr/local/go/bin")
path+=("$HOME/go/bin")
path+=("$HOME/.tmux/plugins/tmuxifier/bin")
path+=("$XDG_CONFIG_HOME/tmux/plugins/tmuxifier/bin")
path+=("$PNPM_HOME")
path+=("/usr/local/bin")
path+=("/usr/bin")
path+=("/usr/local/sbin")
path+=("/usr/sbin")
path+=("/opt/nvim-linux-x86_64/bin")
path+=("$DOTNET_ROOT")
path+=("$DOTNET_ROOT/tools")
path+=("/mnt/c/Windows/System32")
path+=("/mnt/c/Windows/System32/WindowsPowerShell/v1.0")
