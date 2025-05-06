#/usr/bin/env zsh

plugins=(git)

[[ ! -f $ZSH/oh-my-zsh.sh ]] || source $ZSH/oh-my-zsh.sh
[[ ! -f "$HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] || source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
[[ ! -f "$HOME/.zshenv_work" ]] || source "$HOME/.zshenv_work"
[[ ! -f "$HOME/.aliases_work" ]] || source "$HOME/.aliases_work"
[[ ! -f "$HOME/.proxy" ]] || source "$HOME/.proxy"
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

if command -v tmuxifier >/dev/null 2>&1; then
    eval "$(tmuxifier init -)"
fi

if command -v starship >/dev/null 2>&1; then
    eval "$(starship init zsh)"
fi

if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init --cmd cd zsh)"
fi

# bun completions
[ -s "/home/zardios/.bun/_bun" ] && source "/home/zardios/.bun/_bun"

[[ ! -f $HOME/.aliases ]] || source $HOME/.aliases

bindkey '^ ' autosuggest-accept
bindkey -s ^f "tmux-sessionizer\n"

