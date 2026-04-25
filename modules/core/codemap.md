# modules/core/

## Responsibility
Bootstraps foundational developer tooling so other modules can assume basic commands and package-manager support exist.

## Design
Minimal gatekeeper module: `module_check` only verifies `git`; `module_install` installs the core package set and optionally bootstraps `paru` on Arch.

## Data & Control Flow
Runs early in dependency chains. After package installation, Arch-only logic clones the AUR `paru` repo, builds it, then removes the temp checkout.

## Integration Points
Feeds most other modules through `DEPENDS`; relies on `install_packages "core"` and Arch package tooling.
