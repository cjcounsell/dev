#!/usr/bin/env zsh

# Initialize Oh My Zsh with plugins
plugins=(git)
[[ -f "$ZSH/oh-my-zsh.sh" ]] && source "$ZSH/oh-my-zsh.sh"

# Source external configuration files if they exist
local configs=(
  "$HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh"
  "$HOME/.zshenv_work"
  "$HOME/.aliases_work"
  "$HOME/.proxy"
  "$HOME/.aliases"
)
for config in "${configs[@]}"; do
  [[ -f "$config" ]] && source "$config"
done

# Load Bun completions
[[ -s "$HOME/.bun/_bun" ]] && source "$HOME/.bun/_bun"

# Initialize tools if installed
command -v mise >/dev/null 2>&1 && eval "$(mise activate zsh)"
command -v tmuxifier >/dev/null 2>&1 && eval "$(tmuxifier init -)"
command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init --cmd cd zsh)"

# Key bindings
bindkey '^ ' autosuggest-accept
bindkey -s '^f' 'tmux-sessionizer\n'
