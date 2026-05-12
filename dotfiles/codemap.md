# dotfiles/

## Responsibility

Layered dotfile source tree for user, desktop, machine, Windows, and work-specific configuration linked into `$HOME` by `./dev stow`.

## Design

Uses an overlay/layer precedence pattern. `common` provides the baseline, profile layers such as `wsl` or `omarchy` extend it, machine layers such as `g14` override host-specific paths, and optional `windows`/`work` layers sit at the highest precedence when enabled.

## Flow

`dev stow` calls `build_dotfile_layers` and applies each layer through GNU Stow symlink management. For overlapping paths, later layers win because stow runs in precedence order with overrides enabled. `dev promote <path>` copies a chosen file into the machine layer and re-runs stow to make the override explicit.

## Integration

Driven by `config/profiles/*.conf` and `.local/machine.conf`. Consumed by `stow` and `promote` commands in `dev`, with helper logic in `lib/common.sh` and `lib/config.sh`.
