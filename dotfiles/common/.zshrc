#!/usr/bin/env zsh

for f in \
  "$HOME/.config/zsh/init.zsh" \
  "$HOME/.config/zsh/aliases.zsh" \
  "$HOME/.config/zsh/fns.zsh" \
  "$HOME/.config/zsh/work.zsh"
do
  [[ -f "$f" ]] && source "$f"
done

# Source external configuration files if they exist
local configs=(
  "$HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh"
  "$HOME/.zshenv_work"
  "$HOME/.aliases_work"
)
for config in "${configs[@]}"; do
  [[ -f "$config" ]] && source "$config"
done

# Reset terminal cursor color to default on each prompt
precmd() { echo -ne "\e]12;white\a" }

# Key bindings
bindkey '^ ' autosuggest-accept
bindkey -s '^f' 'tmux-sessionizer\n'

# >>> oh-my-opencode-slim background subagents >>>
export OPENCODE_EXPERIMENTAL_BACKGROUND_SUBAGENTS=true
# <<< oh-my-opencode-slim background subagents <<<
