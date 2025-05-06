#!/bin/bash
export STATUS_FILE="$XDG_RUNTIME_DIR/touchpad.status"

enable_touchpad() {
    printf "true" >"$STATUS_FILE"
    notify-send -u normal "Enabling Touchpad" -t 3000
    hyprctl -r keyword '$touchpad_enabled' "true"
}

disable_touchpad() {
    printf "false" >"$STATUS_FILE"
    notify-send -u normal "Disabling Touchpad" -t 3000
    hyprctl -r keyword '$touchpad_enabled' "false"
}

if ! [ -f "$STATUS_FILE" ]; then
  enable_touchpad
else
  if [ $(cat "$STATUS_FILE") = "true" ]; then
    disable_touchpad
  elif [ $(cat "$STATUS_FILE") = "false" ]; then
    enable_touchpad
  fi
fi
