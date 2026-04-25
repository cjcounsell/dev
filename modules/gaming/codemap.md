# modules/gaming/

## Responsibility
Installs gaming launchers and preserves Steam data layout for snapshot-friendly storage.

## Design
Arch-only module with filesystem-aware helper functions. It detects btrfs, migrates or creates a Steam subvolume, then installs gaming packages.

## Data & Control Flow
Checks for Prism Launcher, optionally relocates `~/.local/share/Steam` into a btrfs subvolume, then runs `install_packages "gaming"`.

## Integration Points
Depends on `core` and `cli-tools`; interacts with btrfs, system `sudo`, and user Steam data.
