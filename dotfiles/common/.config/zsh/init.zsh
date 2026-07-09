#!/usr/bin/env zsh

# Initialize Oh My Zsh with plugins
plugins=(git)
[[ -f "$ZSH/oh-my-zsh.sh" ]] && source "$ZSH/oh-my-zsh.sh"

[[ -f "$HOME/.proxy" ]] && source "$HOME/.proxy"
command -v proxyoff >/dev/null 2>&1 && proxyoff

# Initialize tools if installed
command -v mise >/dev/null 2>&1 && eval "$(mise activate zsh)"
command -v tmuxifier >/dev/null 2>&1 && eval "$(tmuxifier init -)"
command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init --cmd cd zsh)"
