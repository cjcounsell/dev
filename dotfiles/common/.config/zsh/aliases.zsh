#!/usr/bin/env zsh

# File system
if command -v eza &> /dev/null; then
  alias ls='eza -lh --group-directories-first --icons=auto'
  alias lsa='ls -a'
  alias lt='eza --tree --level=2 --long --icons --git'
  alias lta='lt -a'
fi

alias ff="fzf --preview 'bat --style=numbers --color=always {}'"
alias eff='$EDITOR "$(ff)"'

# Tools
alias ani-cli="ani-cli --vlc"
alias air="$HOME/go/bin/air"
if command -v batcat >/dev/null 2>&1; then
    alias bat="batcat"
fi
alias cat="bat"
alias lg="lazygit"
alias lzd="lazydocker"
alias sail='[ -f sail ] && sh sail || sh vendor/bin/sail'
alias v="nvim"

# Git
alias g='git'
alias gcm='git commit -m'
alias gcam='git commit -a -m'
alias gcad='git commit -a --amend'
gclp() { git clone git@github.com:cjcounsell/"$1".git; }
