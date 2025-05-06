#!/usr/bin/env zsh

export EDITOR="nvim"
export XDG_CONFIG_HOME="$HOME/.config"
export ZSH="$HOME/.oh-my-zsh"
export BUN_INSTALL="$HOME/.bun"
export NVM_DIR="$HOME/.config/nvm"
export STARSHIP_CONFIG="$HOME/.config/starship.toml"
export XDG_CONFIG_HOME="$HOME/.config"
export GIT_EDITOR=$EDITOR
export DOTFILES=$HOME/.dotfiles
export DOTNET_ROOT=$HOME/.dotnet
export PNPM_HOME="$HOME/.local/share/pnpm"
export CODE_DIRS="$HOME:$HOME/personal:$HOME/work:$HOME/vaults"
export SNACKS_WEZTERM=true

export PHP_INI_SCAN_DIR="/home/cjcounsell/.config/herd-lite/bin:$PHP_INI_SCAN_DIR"
[[ ! -f "$HOME/.deno/env" ]] || . "$HOME/.deno/env"

addToPath() {
    if [[ "$PATH" != *"$1"* ]]; then
        export PATH=$PATH:$1
    fi
}

addToPathFront() {
    if [[ "$PATH" != *"$1"* ]]; then
        export PATH=$1:$PATH
    fi
}

addToPathFront "$HOME/.config/herd-lite/bin"
addToPathFront $BUN_INSTALL/bin
addToPathFront $HOME/.config/composer/vendor/bin
addToPathFront $HOME/.local/bin
addToPathFront $HOME/.local/scripts
addToPathFront /usr/local/go/bin
addToPathFront $HOME/go/bin
addToPathFront $HOME/.tmux/plugins/tmuxifier/bin
addToPathFront $HOME/.config/tmux/plugins/tmuxifier/bin
addToPathFront $PNPM_HOME
addToPathFront "/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin"
addToPath /opt/nvim-linux-x86_64/bin
addToPath $DOTNET_ROOT
addToPath $DOTNET_ROOT/tools
addToPath "/mnt/c/Windows/System32"
addToPath "/mnt/c/Windows/System32/WindowsPowerShell/v1.0"
