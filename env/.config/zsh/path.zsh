# PATH construction
# Uses typeset -U to ensure unique entries

typeset -U PATH path

# User scripts and binaries
path+=("$HOME/.local/bin")
path+=("$HOME/.local/scripts")

# Language runtimes and package managers
path+=("$BUN_INSTALL/bin")
path+=("$PNPM_HOME")
path+=("$DOTNET_ROOT")
path+=("$DOTNET_ROOT/tools")
path+=("/usr/local/go/bin")
path+=("$HOME/go/bin")

# PHP (Herd)
path+=("$HOME/.config/herd-lite/bin")
path+=("$HOME/.config/composer/vendor/bin")

# Tmux
path+=("$HOME/.tmux/plugins/tmuxifier/bin")
path+=("$XDG_CONFIG_HOME/tmux/plugins/tmuxifier/bin")

# Neovim (appimage install location)
path+=("/opt/nvim-linux-x86_64/bin")

# System paths
path+=("/usr/local/bin")
path+=("/usr/bin")
path+=("/usr/local/sbin")
path+=("/usr/sbin")

# WSL-specific paths (only if running in WSL)
[[ -d "/mnt/c/Windows" ]] && {
    path+=("/mnt/c/Windows/System32")
    path+=("/mnt/c/Windows/System32/WindowsPowerShell/v1.0")
}
