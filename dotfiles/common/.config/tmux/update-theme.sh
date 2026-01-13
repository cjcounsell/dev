#!/bin/bash

# Omarchy Theme to Tmux Colors
# Reads colors from Omarchy colors.toml and generates tmux color variables

set -e

# Parse arguments
VERBOSE=false
if [ "$1" = "-v" ] || [ "$1" = "--verbose" ]; then
    VERBOSE=true
fi

# Paths
COLORS_FILE="${HOME}/.config/omarchy/current/theme/colors.toml"
TMUX_THEME_CONF="${XDG_CONFIG_HOME:-$HOME/.config}/tmux/theme.conf"

if [ ! -f "$COLORS_FILE" ]; then
    echo "Error: colors.toml not found at $COLORS_FILE"
    exit 1
fi

echo "Reading theme from: $COLORS_FILE"

if [ "$VERBOSE" = true ]; then
    echo ""
    echo "=== Debug: Parsing colors.toml ==="
fi

# Parse TOML key = "value" format
parse_color() {
    local key=$1
    local line=$(grep "^${key} *= *" "$COLORS_FILE" | head -1)
    
    if [ "$VERBOSE" = true ] && [ -n "$line" ]; then
        echo "  $key: $line" >&2
    fi
    
    if [ -n "$line" ]; then
        echo "$line" | sed -E 's/.*= *"?(#[0-9a-fA-F]{6})"?.*/\1/'
    else
        echo ""
    fi
}

# Extract colors from colors.toml
# Mapping: foreground, color0 (black), color2 (green), color4 (blue), color6 (cyan)
THEME_FG=$(parse_color "foreground")
THEME_GREEN=$(parse_color "color2")
THEME_BLUE=$(parse_color "color4")
THEME_CYAN=$(parse_color "color6")
THEME_BLACK=$(parse_color "color0")

# Fallbacks if parsing failed
[ -z "$THEME_FG" ] && THEME_FG="#D8DEE9"
[ -z "$THEME_GREEN" ] && THEME_GREEN="#A3BE8C"
[ -z "$THEME_BLUE" ] && THEME_BLUE="#81A1C1"
[ -z "$THEME_CYAN" ] && THEME_CYAN="#88C0D0"
[ -z "$THEME_BLACK" ] && THEME_BLACK="#3B4252"

if [ "$VERBOSE" = true ]; then
    echo ""
    echo "=== Extracted Colors ==="
    echo "  THEME_FG: $THEME_FG"
    echo "  THEME_GREEN: $THEME_GREEN"
    echo "  THEME_BLUE: $THEME_BLUE"
    echo "  THEME_CYAN: $THEME_CYAN"
    echo "  THEME_BLACK: $THEME_BLACK"
    echo ""
fi

# Generate tmux theme configuration
cat > "$TMUX_THEME_CONF" << EOF
# Auto-generated from Omarchy theme
# Source: $COLORS_FILE
# Generated: $(date)

# Color Variables
set -g @bg "default"
set -g @default_fg "$THEME_FG"
set -g @session_fg "$THEME_GREEN"
set -g @session_selection_fg "$THEME_BLACK"
set -g @session_selection_bg "$THEME_BLUE"
set -g @active_window_fg "$THEME_CYAN"
set -g @active_pane_border "$THEME_FG"
EOF

echo "Tmux theme colors generated"
echo "  Foreground: $THEME_FG"
echo "  Session (green): $THEME_GREEN"
echo "  Active Window (cyan): $THEME_CYAN"
echo "  Selection (blue): $THEME_BLUE"
echo ""
echo "Run with -v or --verbose flag to see detailed parsing"
