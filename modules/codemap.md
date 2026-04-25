# modules/

## Responsibility
Holds self-contained install modules that configure one concern of a machine: packages, services, tools, and account-level state.

## Design
Each module pairs `meta` (description, deps, profile scope) with `install.sh` (idempotent `module_check`, `module_install`, optional `module_update`). Scripts rely on shared repo helpers and OS guards.

## Data & Control Flow
`./dev install` resolves dependencies from `meta`, sources the module script in a subshell, then runs checks before installation. Modules typically install packages first, then apply user/system configuration or fetch external assets.

## Integration Points
Connects to `config/packages.conf`, profile selection in `config/profiles/*`, shared helpers in `lib/`, and dotfiles under `dotfiles/` when modules depend on shell/editor/runtime state.
