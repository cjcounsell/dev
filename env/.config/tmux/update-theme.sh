#!/bin/bash

# Omarchy Theme to Tmux Colors
# Reads colors from Omarchy theme and generates tmux color variables
# Supports both Kitty and Alacritty theme files

set -e

# Parse arguments
VERBOSE=false
if [ "$1" = "-v" ] || [ "$1" = "--verbose" ]; then
    VERBOSE=true
fi

# Paths - try Kitty first, fall back to Alacritty
KITTY_THEME_FILE="${HOME}/.config/omarchy/current/theme/kitty.conf"
ALACRITTY_THEME_FILE="${HOME}/.config/omarchy/current/theme/alacritty.toml"
TMUX_THEME_CONF="${XDG_CONFIG_HOME:-$HOME/.config}/tmux/theme.conf"

# Determine which theme file to use
if [ -f "$KITTY_THEME_FILE" ]; then
    THEME_FILE="$KITTY_THEME_FILE"
    THEME_TYPE="kitty"
elif [ -f "$ALACRITTY_THEME_FILE" ]; then
    THEME_FILE="$ALACRITTY_THEME_FILE"
    THEME_TYPE="alacritty"
else
    echo "Error: No theme file found"
    echo "  Looked for: $KITTY_THEME_FILE"
    echo "  Looked for: $ALACRITTY_THEME_FILE"
    exit 1
fi

echo "Using $THEME_TYPE theme: $THEME_FILE"

if [ "$VERBOSE" = true ]; then
    echo ""
    echo "=== Debug: Parsing $THEME_TYPE theme ==="
fi

if [ "$THEME_TYPE" = "kitty" ]; then
    # Parse Kitty config format
    # Kitty format: foreground #RRGGBB or color0 #RRGGBB
    parse_kitty_color() {
        local key=$1
        local line=$(grep "^${key}[[:space:]]" "$THEME_FILE" | grep -v "^#" | head -1)
        
        if [ "$VERBOSE" = true ] && [ -n "$line" ]; then
            echo "  $key: $line"
        fi
        
        if [ -n "$line" ]; then
            # Extract hex color from line
            local color=$(echo "$line" | grep -o '#[0-9a-fA-F]\{6\}' | head -1)
            if [ -z "$color" ]; then
                # Try without # prefix
                color=$(echo "$line" | awk '{print $2}' | grep -o '[0-9a-fA-F]\{6\}' | head -1)
                [ -n "$color" ] && color="#$color"
            fi
            echo "$color"
        else
            echo ""
        fi
    }

    # Extract colors from Kitty theme
    THEME_FG=$(parse_kitty_color "foreground")
    THEME_GREEN=$(parse_kitty_color "color2")
    THEME_BLUE=$(parse_kitty_color "color4")
    THEME_CYAN=$(parse_kitty_color "color6")
    THEME_BLACK=$(parse_kitty_color "color0")
    
else
    # Parse Alacritty TOML format
    parse_alacritty_color() {
        local section=$1
        local key=$2
        local color=$(grep -A 20 "^\[colors\.${section}\]" "$THEME_FILE" | grep "^${key} *=" | head -1 | sed -E "s/.*= *['\"]?(#|0x)?([0-9a-fA-F]{6})['\"]?.*/\2/")
        if [ -n "$color" ]; then
            echo "#$color"
        else
            echo ""
        fi
    }

    # Extract colors from Alacritty theme
    THEME_FG=$(parse_alacritty_color "primary" "foreground")
    THEME_GREEN=$(parse_alacritty_color "normal" "green")
    THEME_BLUE=$(parse_alacritty_color "normal" "blue")
    THEME_CYAN=$(parse_alacritty_color "normal" "cyan")
    THEME_BLACK=$(parse_alacritty_color "normal" "black")
fi

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
# Auto-generated from Omarchy theme ($THEME_TYPE)
# Source: $THEME_FILE
# Generated: $(date)

# Color Variables
bg="default"
default_fg="$THEME_FG"
session_fg="$THEME_GREEN"
session_selection_fg="$THEME_BLACK"
session_selection_bg="$THEME_BLUE"
active_window_fg="$THEME_CYAN"
active_pane_border="$THEME_FG"
EOF

echo "✓ Tmux theme colors generated from $THEME_TYPE"
echo "  Foreground: $THEME_FG"
echo "  Session (green): $THEME_GREEN"
echo "  Active Window (cyan): $THEME_CYAN"
echo "  Selection (blue): $THEME_BLUE"
echo ""
echo "Run with -v or --verbose flag to see detailed parsing"
