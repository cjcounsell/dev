#!/usr/bin/env zsh

command -v proxyoff >/dev/null 2>&1 && proxyoff

# Load Bun completions
[[ -s "$HOME/.bun/_bun" ]] && source "$HOME/.bun/_bun"

# Initialize tools if installed
command -v mise >/dev/null 2>&1 && eval "$(mise activate zsh)"
command -v tmuxifier >/dev/null 2>&1 && eval "$(tmuxifier init -)"
command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init --cmd cd zsh)"
