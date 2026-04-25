# modules/node/

## Responsibility
Installs and maintains Node.js 24 via `mise`, plus a global Neovim npm package.

## Design
Version-pinned toolchain module. It requires `mise`, installs the Node runtime globally, then layers on an npm utility package; update is delegated to `mise`.

## Data & Control Flow
Checks for a modern Node major version, installs `node@24`, then runs `npm install -g neovim`.

## Integration Points
Depends on `cli-tools`; provides runtime support for scripting and other language-tooling modules.
