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

# Load NVM
[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
[[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"

# Initialize tools if installed
command -v tmuxifier >/dev/null 2>&1 && eval "$(tmuxifier init -)"
command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init --cmd cd zsh)"

# Key bindings
bindkey '^ ' autosuggest-accept
bindkey -s '^f' 'tmux-sessionizer\n'
