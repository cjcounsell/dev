# config/profiles/

## Responsibility

Profile definitions that bind an environment name to module sets, dotfile layers, and profile-specific hooks.

## Design/Patterns

Small executable Bash manifests with exported scalar metadata and arrays. The pattern is declarative-first: shared modules/layers are listed explicitly, while optional behavior is isolated in named hook functions.

## Data & Control Flow

`load_profile` sources exactly one profile based on `.local/machine.conf`. `dev sync` uses `PROFILE_MODULES`/`PROFILE_DOTFILES` to determine installation and layer precedence, then conditionally invokes a post-sync hook matching `PROFILE_NAME`.

## Integration Points

Interfaces with `dev init`, `lib/config.sh`, `lib/modules.sh`, and `dev sync`. Current profiles: `wsl` (WSL2, no GUI) and `omarchy` (Arch desktop with Hyprland reload via `hyprctl`).
