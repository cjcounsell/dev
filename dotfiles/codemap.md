# dotfiles/

## Responsibility

Layered dotfile source tree for user, desktop, machine, Windows, and work-specific configuration deployed into `$HOME` by `./dev sync`.

## Design

Uses an overlay/layer precedence pattern. `common` provides the baseline, profile layers such as `wsl` or `omarchy` extend it, machine layers such as `g14` override host-specific paths, and optional `windows`/`work` layers sit at the highest precedence when enabled.

## Flow

`dev sync` calls `build_dotfile_layers`, hashes the selected layer set, checks deployed-file drift, and applies each layer with `sync_layer`. For overlapping paths, later layers win; `pull` copies local changes back into the layer chosen by `find_file_layer`.

## Integration

Driven by `config/profiles/*.conf` and `.local/machine.conf`. Consumed by sync, diff, and pull commands in `dev`, with helper logic in `lib/config.sh` and state persisted under `.local/`.
