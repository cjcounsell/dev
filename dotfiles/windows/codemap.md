# dotfiles/windows/

Windows-side desktop configs managed from the dotfiles repo.

## Responsibility

Provides WSL-accessible configuration for Windows UI tools and window management.

## Design

Keeps app configs in a portable `.config` layout so they can be synced from Linux and used on Windows via WSL paths.

## Flow

Files are synced into the user config tree, then read directly by the Windows apps that own them.

## Integration

Integrates with glazewm, yasb, and WezTerm for a Windows desktop setup used alongside WSL.
