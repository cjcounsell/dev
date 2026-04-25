# modules/neovim/

## Responsibility
Provides the Neovim editor, using distro packages where possible and upstream binaries where needed.

## Design
OS-switching install path. Arch uses packages; Ubuntu downloads the latest tarball to `/opt` and replaces any prior install.

## Data & Control Flow
Checks for `nvim` or an `/opt/nvim-linux-x86_64/bin/nvim` binary, then selects the matching install branch.

## Integration Points
Depends on `core`; supports editor usage for shell, Node, and PHP workflows.
