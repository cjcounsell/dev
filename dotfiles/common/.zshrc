#!/usr/bin/env zsh

# Source external configuration files if they exist
local configs=(
  "$HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh"
  "$HOME/.zshenv_work"
  "$HOME/.aliases_work"
  "$HOME/.proxy"
)
for config in "${configs[@]}"; do
  [[ -f "$config" ]] && source "$config"
done

# Key bindings
bindkey '^ ' autosuggest-accept
bindkey -s '^f' 'tmux-sessionizer\n'
