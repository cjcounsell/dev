# modules/php/

## Responsibility
Installs PHP through Herd and optionally provisions an Intelephense license.

## Design
Installer-wrapper module: downloads a temporary Herd script, runs it, then conditionally pulls Bitwarden-backed license data when configured.

## Data & Control Flow
Runs the Herd installer first, then if `BW_INTELEPHENSE_ID` is set, starts a Bitwarden session and writes the license key to a protected file.

## Integration Points
Depends on `core`; integrates with Bitwarden, jq, and editor tooling.
