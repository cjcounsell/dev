# modules/desktop/

## Responsibility
Sets up the Hyprland desktop stack on supported machines.

## Design
Strictly Arch-only. The module is thin: check for `hyprctl`, then delegate package installation to the desktop package group.

## Data & Control Flow
Short-circuits on non-Arch systems with a warning; otherwise installs the desktop package set and exits.

## Integration Points
Depends on `core` and `cli-tools`, and is typically enabled only in the `omarchy` profile.
