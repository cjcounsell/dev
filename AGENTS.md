# Agent Guidelines

## Build/Test Commands
- **Setup**: `./init` - Initialize git submodules
- **Deploy environment**: `./dev-env` - Copies configs from env/ to system (requires DEV_ENV env var)
- **Run setup scripts**: `./run [grep_pattern]` - Executes scripts in runs/ directory (requires DEV_ENV env var)
- **Dry run**: `./run --dry [grep_pattern]` - Preview what would run without executing

## Code Style
- **Language**: Bash shell scripts
- **Shebang**: Always use `#!/usr/bin/env bash` or `#!/usr/bin/env zsh`
- **Error handling**: Use `set -euo pipefail` for strict error handling in setup scripts
- **Functions**: Define helper functions (log, copy, update_files) for reusability
- **Environment**: Check required env vars (DEV_ENV, XDG_CONFIG_HOME) at script start
- **Conditionals**: Use `[[ ]]` for tests, not `[ ]`
- **Command checks**: Use `command -v cmd >/dev/null 2>&1` to check if commands exist
- **Path handling**: Use absolute paths and quote all variables with spaces
- **OS detection**: Use utils/os-detect.sh for cross-platform compatibility (arch/ubuntu)

## File Organization
- **env/**: Configuration files (.config/, .local/, dotfiles)
- **runs/**: Numbered executable setup scripts (0-dev, 1-libs, etc.)
- **utils/**: Shared utility scripts
- **work/**: Work-specific environment configs (git submodule)
