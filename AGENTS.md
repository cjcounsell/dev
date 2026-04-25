# Agent Guidelines

Personal Linux environment manager (Arch/Ubuntu) written in Bash. `./dev` is the real entrypoint; there are no package manifests, CI workflows, or unit tests.

## Verify Changes

```bash
shellcheck dev lib/*.sh modules/*/install.sh
./dev --dry-run sync
./dev doctor
```

- Run `shellcheck` before commits. Use `shellcheck modules/<name>/install.sh` for focused module edits.
- Manual verification is expected; no automated test suite exists.
- Bootstrap/check submodules with `git submodule update --init --recursive` because `dotfiles/work` may be a private submodule.

## CLI Facts Agents Commonly Guess Wrong

```bash
./dev                   # default: status
./dev init              # writes .local/machine.conf after choosing wsl/omarchy
./dev install [MODULE...] # resolves module dependencies; no args = profile + EXTRA_MODULES - SKIP_MODULES
./dev sync [PATH...]    # deploy all or selected dotfiles; aborts on local modifications unless --force
./dev diff [PATH]       # compare repo dotfiles to deployed files
./dev pull <path...>    # copy local changes back into the layer selected by find_file_layer
./dev pull --all        # pull every locally modified tracked dotfile
./dev list | ./dev show <module> | ./dev update | ./dev doctor
```

Global flags parsed before the command: `--dry-run|-n`, `--force|-f`, `--yes|-y`, `--verbose|-v`.

## Architecture Boundaries

- `config/profiles/{wsl,omarchy}.conf` defines `PROFILE_MODULES`, `PROFILE_DOTFILES`, optional modules, and post-sync hooks.
- `config/packages.conf` uses `{category}_{common|arch|ubuntu}` arrays; modules should call `install_packages "category"`, not raw `pacman`/`apt` for packaged deps.
- `modules/<name>/meta` contains `DESCRIPTION`, `DEPENDS=()`, `PROFILES=()`; empty `PROFILES` means all profiles.
- `modules/<name>/install.sh` should define `module_check`, `module_install`, optional `module_update`.
- Module scripts run in a subshell with `common.sh`, `os.sh`, `config.sh`, and `packages.conf` loaded. `DEV_ROOT`, `OS`, `ENV`, `DRY_RUN`, `FORCE`, and `SKIP_CONFIRM` are exported by `./dev`.
- State and generated machine config live in gitignored `.local/`.

## Profiles and Dotfile Layers

- `wsl`: modules `core shell cli-tools ssh neovim tmux node secrets`; dotfiles `common wsl`; optional `php dotnet`.
- `omarchy`: same base plus `desktop networkmanager`; dotfiles `common omarchy`; optional `php dotnet`; post-sync reloads Hyprland with `hyprctl`.
- Layer precedence from low to high: `PROFILE_DOTFILES` (`common`, then profile) → existing `dotfiles/$MACHINE_NAME` (e.g. `g14`) → `windows` if `INCLUDE_WINDOWS=true` → `work` if `INCLUDE_WORK=true`.
- `sync` backs up overwritten items under `~/.config-backups`; selected-file `sync_specific_files` and `pull` use direct `cp`/`rm` paths, so review target layer/path carefully.

## Module Gotchas

- Arch uses `paru` when available; `core` bootstraps `paru` from AUR into `~/paru` and removes it after `makepkg`.
- `desktop` and `networkmanager` are Arch-only and intentionally skip on Ubuntu.
- `cli-tools` fills Ubuntu package-name gaps by symlinking `fdfind→fd` and `batcat→bat`, and adds apt repos for `mise`/`eza` if missing.
- `node` requires `mise`, installs Node.js 24 globally, then `npm install -g neovim`.
- `ssh`, `secrets`, and optional PHP license setup require Bitwarden (`bw_ensure_session`) and env IDs such as `BW_SSH_KEY_ID`, `BW_GH_MCP_TOKEN_ID`, `BW_INTELEPHENSE_ID`.
- `neovim` installs from distro packages on Arch but downloads the latest GitHub tarball to `/opt/nvim` on Ubuntu.

## Bash Conventions in This Repo

- All scripts use `#!/usr/bin/env bash` and `set -euo pipefail`.
- Prefer repo helpers: `error_exit`, `require_command`, `safe_copy`, `safe_remove`, `safe_curl`, `safe_wget`, `install_packages`.
- Quote variables, use `[[ ... ]]`, `$(...)`, and `local` declarations.
- For dotfiles, edit `dotfiles/<layer>/...`; do not write directly into `$HOME` except in module install scripts that intentionally materialize secrets/tools.

## Repository Map

A full codemap is available at `codemap.md` in the project root.

Before working on any task, read `codemap.md` to understand:
- Project architecture and entry points
- Directory responsibilities and design patterns
- Data flow and integration points between modules

For deep work on a specific folder, also read that folder's `codemap.md`.
