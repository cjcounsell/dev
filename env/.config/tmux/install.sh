#!/bin/bash

# Installation script for Omarchy Dynamic Tmux Theme
# This script sets up automatic theme switching for tmux based on Omarchy themes

set -e

TMUX_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/tmux"
HOOK_DIR="$HOME/.local/state/omarchy/theme-hooks/tmux"

echo "==================================="
echo "Omarchy Dynamic Tmux Theme Installer"
echo "==================================="
echo ""
echo "This will set up automatic color switching"
echo "for your minimal tmux status bar."
echo ""
echo "Supports both Kitty and Alacritty theme files!"
echo ""

# Check if Omarchy is installed
if [ ! -d "$HOME/.config/omarchy" ]; then
    echo "⚠️  Warning: Omarchy config directory not found at ~/.config/omarchy"
    echo "   This script is designed for Omarchy. Proceeding anyway..."
    echo ""
elif [ ! -f "$KITTY_THEME_FILE" ] && [ ! -f "$ALACRITTY_THEME_FILE" ]; then
    echo "⚠️  Warning: No terminal theme file found"
    echo "   Looked for: $KITTY_THEME_FILE"
    echo "   Looked for: $ALACRITTY_THEME_FILE"
    echo "   Proceeding anyway..."
    echo ""
fi

# Create tmux config directory if it doesn't exist
mkdir -p "$TMUX_CONFIG_DIR"

# Install update-theme.sh script
echo "📝 Installing update-theme.sh..."
cat > "$TMUX_CONFIG_DIR/update-theme.sh" << 'SCRIPT_EOF'
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
SCRIPT_EOF

chmod +x "$TMUX_CONFIG_DIR/update-theme.sh"
echo "✅ update-theme.sh installed"

# Install Omarchy hook (optional)
echo ""
echo "Note: Omarchy doesn't currently have a built-in theme hook system."
echo "You'll need to manually update tmux after changing themes."
echo ""
read -p "📦 Create a manual theme-update script anyway? [Y/n] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then
    # Create a convenient update script
    cat > "$TMUX_CONFIG_DIR/sync-omarchy-theme.sh" << 'SYNC_EOF'
#!/bin/bash
# Quick script to update tmux theme from Omarchy
"${XDG_CONFIG_HOME:-$HOME/.config}/tmux/update-theme.sh"
if command -v tmux &> /dev/null; then
    if tmux list-sessions &> /dev/null 2>&1; then
        tmux source-file "${XDG_CONFIG_HOME:-$HOME/.config}/tmux/tmux.conf"
        echo "✓ Tmux theme synced with Omarchy!"
    else
        echo "✓ Theme colors generated (start tmux to see changes)"
    fi
fi
SYNC_EOF
    chmod +x "$TMUX_CONFIG_DIR/sync-omarchy-theme.sh"
    echo "✅ Sync script created at $TMUX_CONFIG_DIR/sync-omarchy-theme.sh"
    
    # Offer to create alias
    echo ""
    read -p "📌 Add 'tmux-sync' alias to your shell config? [Y/n] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then
        SHELL_RC=""
        if [ -n "$ZSH_VERSION" ]; then
            SHELL_RC="$HOME/.zshrc"
        elif [ -n "$BASH_VERSION" ]; then
            SHELL_RC="$HOME/.bashrc"
        fi
        
        if [ -n "$SHELL_RC" ]; then
            echo "" >> "$SHELL_RC"
            echo "# Omarchy tmux theme sync" >> "$SHELL_RC"
            echo "alias tmux-sync='$TMUX_CONFIG_DIR/sync-omarchy-theme.sh'" >> "$SHELL_RC"
            echo "✅ Alias added to $SHELL_RC"
            echo "   Run 'tmux-sync' after changing Omarchy themes"
        fi
    fi
else
    echo "⏭️  Skipped sync script creation"
fi

# Backup existing tmux.conf
if [ -f "$TMUX_CONFIG_DIR/tmux.conf" ]; then
    echo ""
    echo "📋 Your existing tmux.conf will be preserved."
    echo "   You just need to add one line to it (see instructions below)."
fi

# Run theme generation for the first time
echo ""
echo "🎨 Generating initial theme..."
"$TMUX_CONFIG_DIR/update-theme.sh"

echo ""
echo "==================================="
echo "✅ Installation Complete!"
echo "==================================="
echo ""
echo "📋 Summary of installed files:"
echo "   - $TMUX_CONFIG_DIR/update-theme.sh (theme parser)"
echo "   - $TMUX_CONFIG_DIR/theme.conf (generated color variables)"
if [ -f "$TMUX_CONFIG_DIR/sync-omarchy-theme.sh" ]; then
    echo "   - $TMUX_CONFIG_DIR/sync-omarchy-theme.sh (quick sync script)"
fi
echo ""
echo "⚙️  Your minimal status bar will use these dynamic colors!"
echo ""
echo "Next steps:"
echo "1. Update your tmux.conf to source the theme colors:"
echo "   Add this line at the top of your status bar section:"
echo "   source-file \"$TMUX_CONFIG_DIR/theme.conf\""
echo ""
echo "2. Remove the hardcoded color variable definitions (bg, default_fg, etc.)"
echo "   They're now in theme.conf and will update automatically!"
echo ""
echo "3. Reload tmux: tmux source-file ~/.config/tmux/tmux.conf"
echo "4. Or press PREFIX + r to reload (Ctrl+Space, then r)"
echo ""
echo "When you change themes in Omarchy, update tmux with:"
if [ -f "$TMUX_CONFIG_DIR/sync-omarchy-theme.sh" ]; then
    if grep -q "alias tmux-sync=" "$HOME/.zshrc" 2>/dev/null || grep -q "alias tmux-sync=" "$HOME/.bashrc" 2>/dev/null; then
        echo "  → Just run: tmux-sync"
    else
        echo "  → Run: $TMUX_CONFIG_DIR/sync-omarchy-theme.sh"
    fi
else
    echo "  → Run: $TMUX_CONFIG_DIR/update-theme.sh"
    echo "  → Then: tmux source ~/.config/tmux/tmux.conf (or Ctrl+Space + r)"
fi
echo ""
echo "💡 Tip: You can also press Ctrl+Space + r inside tmux to reload!"
echo ""
echo "Happy theming! 🎨"
