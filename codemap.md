# Repository Atlas: dev

## Project Responsibility

Personal Linux environment manager for Arch, Ubuntu, WSL, and Omarchy/Hyprland machines. The repository combines a Bash CLI, declarative machine profiles, idempotent install modules, and layered dotfiles to bootstrap and keep development environments synchronized.

## System Entry Points

- `dev`: Main Bash CLI. Parses global flags, detects OS/environment, loads runtime libraries, and dispatches commands such as `init`, `install`, `sync`, `diff`, `pull`, `list`, `show`, `update`, and `doctor`.
- `README.md`: Human quick-start and command overview.
- `AGENTS.md`: Agent-facing operational constraints and repository facts.
- `.local/machine.conf` (gitignored): Generated machine selection state consumed by the CLI.

## Core Control Flow

1. `./dev init` detects the host, prompts for a profile (`wsl` or `omarchy`), and writes `.local/machine.conf`.
2. `./dev install [MODULE...]` loads the active profile, resolves module dependencies from `modules/*/meta`, and runs each `modules/*/install.sh` in an isolated module execution context.
3. `./dev sync [PATH...]` builds dotfile layers from profile, machine, Windows, and work settings; checks for local drift; applies files into `$HOME`; runs profile post-sync hooks; and stores a sync hash in `.local/state`.
4. `./dev diff` and `./dev pull` compare deployed files against layer sources and optionally copy local changes back into the appropriate layer.
5. `./dev doctor` validates machine config, profile/module metadata, expected dependencies, and dotfile state.

## Directory Map

| Directory | Responsibility Summary | Detailed Map |
|-----------|------------------------|--------------|
| `lib/` | Shared Bash runtime for logging, OS detection, package installs, config loading, module orchestration, safe filesystem operations, and state persistence. | [View Map](lib/codemap.md) |
| `config/` | Declarative package-category arrays and profile manifests consumed by the runtime. | [View Map](config/codemap.md) |
| `config/profiles/` | Profile definitions that bind environment names to module lists, dotfile layers, optional modules, and post-sync hooks. | [View Map](config/profiles/codemap.md) |
| `modules/` | Self-contained installation modules with `meta` dependency/profile declarations and idempotent `install.sh` hooks. | [View Map](modules/codemap.md) |
| `dotfiles/` | Layered dotfile source tree deployed to `$HOME` with common, profile, machine, Windows, and work overlays. | [View Map](dotfiles/codemap.md) |

## Dotfile Layer Maps

| Layer | Responsibility Summary | Detailed Map |
|-------|------------------------|--------------|
| `dotfiles/common/` | Shared shell, terminal, editor, prompt, tmux, Git, Kitty, and helper-script baseline used by all profiles. | [View Map](dotfiles/common/codemap.md) |
| `dotfiles/omarchy/` | Omarchy/Hyprland desktop overrides for monitors, bindings, look-and-feel, autostart, windows, Waybar, and theme hooks. | [View Map](dotfiles/omarchy/codemap.md) |
| `dotfiles/wsl/` | WSL-specific overlay for Linux configs running alongside Windows. | [View Map](dotfiles/wsl/codemap.md) |
| `dotfiles/g14/` | ASUS ROG Zephyrus G14 host layer for power, touchpad, GPU, Hyprland, systemd user, and udev customization. | [View Map](dotfiles/g14/codemap.md) |
| `dotfiles/windows/` | WSL-managed Windows desktop configs for tools such as glazewm, yasb, and WezTerm. | [View Map](dotfiles/windows/codemap.md) |
| `dotfiles/work/` | Private work-context overlay for Git config, proxy/env wiring, local scripts, and internal tooling. | [View Map](dotfiles/work/codemap.md) |

## Module Maps

| Module | Responsibility Summary | Detailed Map |
|--------|------------------------|--------------|
| `core` | Base system packages and AUR helper bootstrap. | [View Map](modules/core/codemap.md) |
| `cli-tools` | CLI productivity packages, Ubuntu naming shims, and third-party apt repositories. | [View Map](modules/cli-tools/codemap.md) |
| `shell` | Zsh and shell integration setup. | [View Map](modules/shell/codemap.md) |
| `ssh` | Bitwarden-backed SSH key materialization. | [View Map](modules/ssh/codemap.md) |
| `neovim` | Neovim installation, using packages on Arch and upstream tarballs on Ubuntu. | [View Map](modules/neovim/codemap.md) |
| `tmux` | Tmux installation and plugin/config support. | [View Map](modules/tmux/codemap.md) |
| `node` | mise-managed Node.js 24 and npm Neovim provider setup. | [View Map](modules/node/codemap.md) |
| `secrets` | Bitwarden-backed secret/environment materialization. | [View Map](modules/secrets/codemap.md) |
| `desktop` | Arch-only desktop/Omarchy package and environment setup. | [View Map](modules/desktop/codemap.md) |
| `networkmanager` | Arch-only NetworkManager setup. | [View Map](modules/networkmanager/codemap.md) |
| `gaming` | Gaming-related package setup. | [View Map](modules/gaming/codemap.md) |
| `php` | Optional PHP tooling and license integration. | [View Map](modules/php/codemap.md) |
| `dotnet` | Optional .NET SDK/tooling setup. | [View Map](modules/dotnet/codemap.md) |

## Integration Boundaries

- Module scripts should use helpers and package categories instead of direct raw package-manager calls when packaged dependencies are available.
- Dotfile edits belong under `dotfiles/<layer>/...`; `$HOME` writes should only happen through sync/pull logic or intentional module materialization.
- Generated and host-local state belongs in `.local/`, which is excluded from version control.
- Work/private dotfiles are treated as high-precedence overlays and should be summarized carefully to avoid exposing sensitive details.
