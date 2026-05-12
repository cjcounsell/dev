# dev

Personal development environment manager for Linux (Arch/Ubuntu).

## Quick Start

```bash
git clone git@github.com:cjcounsell/dev ~/personal/dev
cd ~/personal/dev
git submodule update --init --recursive

./dev init        # Select profile (wsl or omarchy)
./dev install     # Install all modules
./dev stow        # Deploy dotfiles as GNU Stow symlinks
```

## Commands

| Command                     | Description                                          |
| --------------------------- | ---------------------------------------------------- |
| `./dev`                     | Show status                                          |
| `./dev init`                | First-time setup                                     |
| `./dev stow`                | Deploy dotfiles using GNU Stow symlinks              |
| `./dev promote <path>`      | Copy one dotfile into the machine layer, then restow |
| `./dev install [module...]` | Install module(s)                                    |
| `./dev list`                | List available modules                               |
| `./dev update`              | Update system packages                               |
| `./dev doctor`              | Check for issues                                     |

## Dotfile Management

Dotfiles are managed through **GNU Stow symlinks**:

- `./dev stow` links layered files from `dotfiles/<layer>/...` into `$HOME`.
- Higher-precedence layers override lower ones.
- `./dev --force stow` uses Stow `--adopt` to import existing local files into the repo before linking.
- `./dev promote <path>` is used when a shared file needs a machine-specific override.

## Profiles

- **wsl** - WSL2 development (no GUI packages)
- **omarchy** - Full Arch desktop with Hyprland

## Customization

After `./dev init`, edit `.local/machine.conf`:

```bash
PROFILE="wsl"
MACHINE_NAME="my-laptop"
EXTRA_MODULES=(php dotnet)  # Add optional modules
SKIP_MODULES=()             # Skip specific modules
INCLUDE_WINDOWS=false       # Include Windows desktop configs (yasb, glazewm)
INCLUDE_WORK=true           # Include work dotfiles layer
```
