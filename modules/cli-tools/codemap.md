# modules/cli-tools/

## Responsibility
Installs common command-line utilities and fills OS-specific gaps so later modules can depend on a consistent toolset.

## Design
Package-first, then Ubuntu-specific compatibility fixes. Uses symlinks for renamed binaries and conditionally adds external apt repos when distro packages are missing.

## Data & Control Flow
Checks for `fzf`, `rg`, `eza`, and `mise`. Install flow uses `install_packages "cli"`, then Ubuntu-only symlink/repo setup if needed.

## Integration Points
Supports `node`, `shell`, and other tooling-heavy modules; depends on `core` and Ubuntu apt/keyring infrastructure.
