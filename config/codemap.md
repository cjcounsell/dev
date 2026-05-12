# config/

## Responsibility

Declarative configuration for package categories and profile bootstrap data consumed by the Bash runtime.

## Design/Patterns

Shell variable tables with OS-specific suffixing (`*_common`, `*_arch`, `*_ubuntu`) and profile scripts that export metadata plus optional hook functions. No imperative orchestration lives here beyond profile-specific post-stow behavior.

## Data & Control Flow

`lib/config.sh` sources `packages.conf` on demand and profile files by name. `lib/os.sh` resolves package arrays by category and current `OS`; `dev init` writes `.local/machine.conf` to select a profile, which later drives module and dotfile layer selection.

## Integration Points

Consumed by `lib/config.sh`, `lib/os.sh`, and `dev`. `packages.conf` feeds `install_packages`; `profiles/*.conf` provide `PROFILE_NAME`, `PROFILE_DESC`, `PROFILE_MODULES`, `PROFILE_DOTFILES`, `OPTIONAL_MODULES`, and profile hooks such as `omarchy_post_sync` (invoked after `dev stow`).
