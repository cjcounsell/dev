# modules/tmux/

## Responsibility
Installs the tmux terminal multiplexer.

## Design
Single-purpose package module with a one-line check/install pair.

## Data & Control Flow
Verifies `tmux` exists; if not, installs the tmux package group.

## Integration Points
Depends on `core` and provides terminal session support for shell workflows.
