# modules/shell/

## Responsibility
Configures the interactive shell stack: Zsh, Oh My Zsh, Starship, and useful plugins.

## Design
Layered bootstrap with package install first, then optional Starship install on Ubuntu, then repo-based plugin setup and default-shell switching.

## Data & Control Flow
Checks for Zsh, OMZ, and Starship. Installs packages, downloads scripts into temp files, clones autosuggestions, and updates the login shell if needed.

## Integration Points
Depends on `core`; feeds developer UX for almost every other module through shell startup and prompt configuration.
