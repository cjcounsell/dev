# lib/

## Responsibility

Shared Bash runtime for the CLI: logging, safe filesystem operations, OS/package abstraction, config loading, module orchestration, and persisted state handling.

## Design/Patterns

Pure shell helper library with `source`-time initialization and function-level APIs. Uses defensive checks (`error_exit`, `safe_source`), associative arrays for log levels, nameref-based package aggregation, and subshell isolation for module execution.

## Data & Control Flow

`dev` sources these files in a fixed order (`common → os → config → modules → state`), then passes global context (`DEV_ROOT`, `OS`, `ENV`, `DRY_RUN`, `PROFILE`) into command handlers. Config/state functions read and write `.local/*`; module resolution walks dependency graphs recursively before invoking install/update hooks.

## Integration Points

Called directly by `dev` and indirectly by module install scripts. Integrates with `config/packages.conf`, `config/profiles/*.conf`, `modules/*/meta`, `modules/*/install.sh`, `bw`, `jq`, `paru`, `pacman`, `apt-get`, and backup paths under `~/.config-backups`.
