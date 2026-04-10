#!/usr/bin/env zsh

# Source proxy functions before modular configs (init.zsh calls proxyoff)
[[ -f "$HOME/.proxy" ]] && source "$HOME/.proxy"

# Source modular configuration files
for f in "$HOME/.config/zsh"/*.zsh; do
    [[ -f "$f" ]] && source "$f"
done
