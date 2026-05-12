# dotfiles/wsl/

WSL-specific overlay for Linux configs.

## Responsibility

Adjusts shell and desktop-adjacent behavior for Linux running under WSL.

## Design

Keeps WSL-only hooks separate from the common layer so native Linux hosts avoid Windows-aware tweaks.

## Flow

The profile includes this layer automatically, then its files override or extend shared configs when `./dev stow` links active layers into `$HOME`.

## Integration

Works with the `wsl` profile and Windows filesystem access patterns; currently focused on Omarchy hook/theme assets.
