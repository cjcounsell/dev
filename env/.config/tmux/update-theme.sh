#!/bin/bash

# Omarchy Theme to Catppuccin Variables Mapper
# Reads colors from Omarchy theme and maps them to Catppuccin tmux plugin variables

set -e

# Paths
OMARCHY_THEME_FILE="${HOME}/.config/omarchy/current/theme/alacritty.toml"
TMUX_THEME_CONF="${XDG_CONFIG_HOME:-$HOME/.config}/tmux/theme.conf"

# Check if theme file exists
if [ ! -f "$OMARCHY_THEME_FILE" ]; then
    echo "Error: Omarchy theme file not found at $OMARCHY_THEME_FILE"
    exit 1
fi

# Parse TOML file for colors
parse_color() {
    local section=$1
    local key=$2
    local color=$(grep -A 20 "^\[colors\.${section}\]" "$OMARCHY_THEME_FILE" | grep "^${key} *=" | head -1 | sed -E "s/.*= *['\"]?(#|0x)?([0-9a-fA-F]{6})['\"]?.*/\2/")
    if [ -n "$color" ]; then
        echo "#$color"
    else
        echo ""
    fi
}

# Extract colors from Alacritty theme
THEME_BG=$(parse_color "primary" "background")
THEME_FG=$(parse_color "primary" "foreground")

# Normal colors
THEME_BLACK=$(parse_color "normal" "black")
THEME_RED=$(parse_color "normal" "red")
THEME_GREEN=$(parse_color "normal" "green")
THEME_YELLOW=$(parse_color "normal" "yellow")
THEME_BLUE=$(parse_color "normal" "blue")
THEME_MAGENTA=$(parse_color "normal" "magenta")
THEME_CYAN=$(parse_color "normal" "cyan")
THEME_WHITE=$(parse_color "normal" "white")

# Bright colors
THEME_BRIGHT_BLACK=$(parse_color "bright" "black")
THEME_BRIGHT_RED=$(parse_color "bright" "red")
THEME_BRIGHT_GREEN=$(parse_color "bright" "green")
THEME_BRIGHT_YELLOW=$(parse_color "bright" "yellow")
THEME_BRIGHT_BLUE=$(parse_color "bright" "blue")
THEME_BRIGHT_MAGENTA=$(parse_color "bright" "magenta")
THEME_BRIGHT_CYAN=$(parse_color "bright" "cyan")
THEME_BRIGHT_WHITE=$(parse_color "bright" "white")

# Fallbacks
[ -z "$THEME_BG" ] && THEME_BG="#1e2127"
[ -z "$THEME_FG" ] && THEME_FG="#abb2bf"
[ -z "$THEME_BLUE" ] && THEME_BLUE="#61afef"
[ -z "$THEME_CYAN" ] && THEME_CYAN="#56b6c2"
[ -z "$THEME_MAGENTA" ] && THEME_MAGENTA="#c678dd"
[ -z "$THEME_YELLOW" ] && THEME_YELLOW="#d19a66"
[ -z "$THEME_GREEN" ] && THEME_GREEN="#98c379"
[ -z "$THEME_RED" ] && THEME_RED="#e06c75"

# Function to create surface variants (lighter shades of background)
create_surface() {
    local hex=$1
    local factor=${2:-1.15}
    hex=${hex#\#}
    r=$((16#${hex:0:2}))
    g=$((16#${hex:2:2}))
    b=$((16#${hex:4:2}))
    r=$(awk "BEGIN {printf \"%.0f\", $r * $factor; exit}")
    g=$(awk "BEGIN {printf \"%.0f\", $g * $factor; exit}")
    b=$(awk "BEGIN {printf \"%.0f\", $b * $factor; exit}")
    r=$((r > 255 ? 255 : r))
    g=$((g > 255 ? 255 : g))
    b=$((b > 255 ? 255 : b))
    printf "#%02x%02x%02x" $r $g $b
}

# Create surface color variants (Catppuccin uses multiple surface layers)
SURFACE_0=$(create_surface "$THEME_BG" 1.15)
SURFACE_1=$(create_surface "$THEME_BG" 1.25)
SURFACE_2=$(create_surface "$THEME_BG" 1.35)

# Generate Catppuccin-compatible variable mapping
cat > "$TMUX_THEME_CONF" << EOF
# Auto-generated Catppuccin variable overrides from Omarchy theme
# Source: $OMARCHY_THEME_FILE
# Generated: $(date)

# Base colors (Catppuccin naming)
set -g @thm_bg "$THEME_BG"           # Base/Background
set -g @thm_fg "$THEME_FG"           # Text
set -g @thm_text "$THEME_FG"         # Text (alias)

# Surface layers (progressively lighter backgrounds)
set -g @thm_surface_0 "$SURFACE_0"   # Surface 0
set -g @thm_surface_1 "$SURFACE_1"   # Surface 1
set -g @thm_surface_2 "$SURFACE_2"   # Surface 2
set -g @thm_overlay_0 "${THEME_BRIGHT_BLACK:-$SURFACE_2}"  # Overlay 0

# Accent colors (mapped from terminal colors)
set -g @thm_blue "$THEME_BLUE"       # Blue
set -g @thm_lavender "$THEME_CYAN"   # Lavender (mapped to cyan)
set -g @thm_sapphire "$THEME_BLUE"   # Sapphire
set -g @thm_sky "$THEME_CYAN"        # Sky
set -g @thm_teal "$THEME_CYAN"       # Teal
set -g @thm_green "$THEME_GREEN"     # Green
set -g @thm_yellow "$THEME_YELLOW"   # Yellow
set -g @thm_peach "$THEME_YELLOW"    # Peach (orange-yellow)
set -g @thm_maroon "$THEME_RED"      # Maroon
set -g @thm_red "$THEME_RED"         # Red
set -g @thm_mauve "$THEME_MAGENTA"   # Mauve
set -g @thm_pink "$THEME_MAGENTA"    # Pink
set -g @thm_flamingo "$THEME_MAGENTA" # Flamingo
set -g @thm_rosewater "$THEME_MAGENTA" # Rosewater

# Additional semantic colors
set -g @thm_subtext_1 "${THEME_WHITE:-$THEME_FG}"
set -g @thm_subtext_0 "${THEME_BRIGHT_BLACK:-$SURFACE_2}"
set -g @thm_overlay_1 "${THEME_BRIGHT_BLACK:-$SURFACE_2}"
set -g @thm_overlay_2 "${THEME_WHITE:-$THEME_FG}"
set -g @thm_mantle "$THEME_BLACK"
set -g @thm_crust "$THEME_BLACK"
EOF

echo "✓ Catppuccin color variables updated from Omarchy theme"
echo "  Background: $THEME_BG"
echo "  Foreground: $THEME_FG"
echo "  Accent (Blue): $THEME_BLUE"
echo "  Accent (Yellow): $THEME_YELLOW"
