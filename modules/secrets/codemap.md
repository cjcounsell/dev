# modules/secrets/

## Responsibility
Sets up Bitwarden CLI access and materializes secret files used by other modules.

## Design
Credential-gated module that installs `bw` only when missing, ensures an authenticated session, then writes secrets into `~/.secrets` with strict permissions.

## Data & Control Flow
Checks for both `bw` and `~/.secrets`; installs the CLI if needed, fetches the GitHub MCP token when configured, and logs success.

## Integration Points
Depends on `core` and `node`; underpins `ssh` and `php` via shared Bitwarden item IDs.
