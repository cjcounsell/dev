# dotfiles/common/

Shared baseline dotfiles used across profiles and machines.

## Responsibility

Provides common shell, terminal, editor, and prompt configuration plus a few helper scripts. It also stores generic integration glue that other layers extend.

## Design

Layered config by tool: zsh sources optional local files, tmux pulls theme data, and Neovim bootstraps a plugin stack from a tiny entrypoint. Sensitive values live in separate secret files.

## Flow

Shell startup loads zsh init files, then conditionally sources machine/work overrides. Neovim and tmux read their own config trees at launch, and helper scripts are invoked by aliases or theme hooks.

## Integration

Used by both WSL and desktop profiles as the common dotfile layer. Connects to external tools such as mise, starship, zoxide, tmux, and Bitwarden-backed secret lookups.
