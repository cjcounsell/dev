### Install TPM

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
~/.tmux/plugins/tpm/tpm
```

# Tmux Color Variables → Terminal Theme Mapping

This document shows how your tmux color variables are mapped from your Omarchy terminal theme colors.

## Variable Mapping

| Tmux Variable | Kitty | Alacritty | Usage |
|--------------|-------|-----------|-------|
| `bg` | `"default"` | `"default"` | Status bar background (transparent) |
| `default_fg` | `foreground` | `colors.primary.foreground` | Default text color |
| `session_fg` | `color2` | `colors.normal.green` | Session name color (green) |
| `session_selection_fg` | `color0` | `colors.normal.black` | Selection text (dark) |
| `session_selection_bg` | `color4` | `colors.normal.blue` | Selection background |
| `active_window_fg` | `color6` | `colors.normal.cyan` | Active window text (cyan) |
| `active_pane_border` | `foreground` | `colors.primary.foreground` | Active pane border |

## Color Sources

The script automatically detects which terminal you're using:

1. **Kitty**: `~/.config/omarchy/current/theme/kitty.conf`
2. **Alacritty**: `~/.config/omarchy/current/theme/alacritty.toml` (fallback)

### Kitty Theme Format

```conf
foreground #D8DEE9
background #2E3440

# Normal colors (color0-7)
color0 #3B4252  # black   → session_selection_fg
color1 #BF616A  # red
color2 #A3BE8C  # green   → session_fg
color3 #EBCB8B  # yellow
color4 #81A1C1  # blue    → session_selection_bg
color5 #B48EAD  # magenta
color6 #88C0D0  # cyan    → active_window_fg
color7 #E5E9F0  # white

# Bright colors (color8-15)
color8  #4C566A  # bright black
color9  #BF616A  # bright red
# ... etc
```

### Alacritty Theme Format

```toml
[colors.primary]
foreground = '#D8DEE9'  # → default_fg, active_pane_border
background = '#2E3440'  # (not used)

[colors.normal]
black   = '#3B4252'  # → session_selection_fg
red     = '#BF616A'
green   = '#A3BE8C'  # → session_fg
yellow  = '#EBCB8B'
blue    = '#81A1C1'  # → session_selection_bg
magenta = '#B48EAD'
cyan    = '#88C0D0'  # → active_window_fg
white   = '#E5E9F0'
```

## Generated File

When you run `~/.config/tmux/update-theme.sh`, it creates `~/.config/tmux/theme.conf`:

```bash
# Auto-generated from Omarchy theme (kitty)
bg="default"
default_fg="#D8DEE9"
session_fg="#A3BE8C"
session_selection_fg="#3B4252"
session_selection_bg="#81A1C1"
active_window_fg="#88C0D0"
active_pane_border="#D8DEE9"
```

## Customizing the Mapping

Edit `~/.config/tmux/update-theme.sh` to change which colors map to which variables.

### For Kitty:
```bash
# Use magenta (color5) for session instead of green (color2)
THEME_GREEN=$(parse_kitty_color "color5")

# Use bright blue (color12) for selection
THEME_BLUE=$(parse_kitty_color "color12")
```

### For Alacritty:
```bash
# Use magenta for session instead of green
THEME_GREEN=$(parse_alacritty_color "normal" "magenta")

# Use bright blue for selection
THEME_BLUE=$(parse_alacritty_color "bright" "blue")
```

## Kitty Color Reference

- `color0-7`: Normal colors (black, red, green, yellow, blue, magenta, cyan, white)
- `color8-15`: Bright colors (same order as normal)
- `foreground`, `background`: Primary colors
