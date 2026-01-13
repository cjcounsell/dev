### Install TPM

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
~/.tmux/plugins/tpm/tpm
```

# Tmux Color Variables - Omarchy Theme Mapping

This document shows how tmux color variables are mapped from your Omarchy theme's `colors.toml`.

## Variable Mapping

| Tmux Variable | colors.toml Key | Usage |
|--------------|-----------------|-------|
| `bg` | `"default"` | Status bar background (transparent) |
| `default_fg` | `foreground` | Default text color |
| `session_fg` | `color2` | Session name color (green) |
| `session_selection_fg` | `color0` | Selection text (dark/black) |
| `session_selection_bg` | `color4` | Selection background (blue) |
| `active_window_fg` | `color6` | Active window text (cyan) |
| `active_pane_border` | `foreground` | Active pane border |

## Color Source

The script reads from: `~/.config/omarchy/current/theme/colors.toml`

### colors.toml Format

```toml
accent = "#7aa2f7"
cursor = "#c0caf5"
foreground = "#a9b1d6"
background = "#1a1b26"
selection_foreground = "#c0caf5"
selection_background = "#7aa2f7"

color0 = "#32344a"   # black   -> session_selection_fg
color1 = "#f7768e"   # red
color2 = "#9ece6a"   # green   -> session_fg
color3 = "#e0af68"   # yellow
color4 = "#7aa2f7"   # blue    -> session_selection_bg
color5 = "#ad8ee6"   # magenta
color6 = "#449dab"   # cyan    -> active_window_fg
color7 = "#787c99"   # white
color8-15 = ...      # bright variants
```

## Generated File

Running `~/.config/tmux/update-theme.sh` creates `~/.config/tmux/theme.conf`:

```bash
set -g @bg "default"
set -g @default_fg "#a9b1d6"
set -g @session_fg "#9ece6a"
set -g @session_selection_fg "#32344a"
set -g @session_selection_bg "#7aa2f7"
set -g @active_window_fg "#449dab"
set -g @active_pane_border "#a9b1d6"
```

## Customizing the Mapping

Edit `~/.config/tmux/update-theme.sh` to change which colors map to which variables:

```bash
# Use magenta (color5) for session instead of green (color2)
THEME_GREEN=$(parse_color "color5")

# Use bright blue (color12) for selection
THEME_BLUE=$(parse_color "color12")
```

## Color Reference

Standard ANSI color indices in colors.toml:
- `color0-7`: Normal colors (black, red, green, yellow, blue, magenta, cyan, white)
- `color8-15`: Bright colors (same order as normal)
- `foreground`, `background`: Primary colors
- `accent`, `cursor`, `selection_*`: Additional theme colors
