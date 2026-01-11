#!/usr/bin/env zsh

# Source modular configuration files
for f in "$HOME/.config/zsh"/*.zsh; do
    [[ -f "$f" ]] && source "$f"
done
