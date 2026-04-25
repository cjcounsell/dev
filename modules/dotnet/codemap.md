# modules/dotnet/

## Responsibility
Bootstraps and updates the .NET SDK plus common global dotnet tools.

## Design
Script-managed runtime install. Keeps `dotnet-install.sh` under `~/.local/scripts`, uses LTS channel installs, and layers global tooling afterward.

## Data & Control Flow
Downloads the installer once, runs it for LTS, exports `DOTNET_ROOT`, then installs or updates CSharpier and EasyDotnet. Update reuses the saved installer.

## Integration Points
Depends on `core`; supports C# formatting and project workflows, and uses external dotnet distribution scripts.
