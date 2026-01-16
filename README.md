# dev

Personal development environment manager for Linux (Arch/Ubuntu).

## Quick Start

```bash
git clone git@github.com:cjcounsell/dev ~/personal/dev
cd ~/personal/dev
git submodule update --init --recursive

./dev init        # Select profile (wsl or omarchy)
./dev install     # Install all modules
./dev sync        # Deploy dotfiles
```

## Commands

| Command | Description |
|---------|-------------|
| `./dev` | Show status |
| `./dev init` | First-time setup |
| `./dev sync` | Deploy dotfiles |
| `./dev install [module...]` | Install module(s) |
| `./dev list` | List available modules |
| `./dev update` | Update system packages |
| `./dev doctor` | Check for issues |

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
