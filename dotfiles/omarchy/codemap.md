# dotfiles/omarchy/

Desktop-layer overrides for the Omarchy/Hyprland environment.

## Responsibility

Customizes the Linux desktop experience with Hyprland, Waybar, and theme hooks on top of Omarchy defaults.

## Design

Uses a split model: shared defaults are sourced first, then local config files override selected areas without editing generated defaults.

## Flow

Hyprland loads default configs, then the local layer files for monitors, bindings, envs, look-and-feel, autostart, and windows. Waybar reads its JSONC config and launches status modules that invoke Omarchy helper commands.

## Integration

Integrates with Hyprland, Waybar, theme switching hooks, and Omarchy CLI helpers; the theme-set hook also bridges into tmux theming.
