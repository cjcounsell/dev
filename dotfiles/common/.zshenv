#!/usr/bin/env zsh

for f in \
  "$HOME/.config/zsh/env.zsh" \
  "$HOME/.config/zsh/path.zsh" \
  "$HOME/.config/zsh/secrets.zsh"
do
  [[ -f "$f" ]] && source "$f"
done
