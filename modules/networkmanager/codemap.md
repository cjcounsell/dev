# modules/networkmanager/

## Responsibility
Configures NetworkManager as the active network stack and disables conflicting services.

## Design
Arch-only service orchestration module. It installs the networkmanager package group, then explicitly disables iwd/systemd-networkd before enabling NetworkManager.

## Data & Control Flow
Checks service enablement and `nmcli`; install path toggles services with `systemctl` and ends with a reboot recommendation.

## Integration Points
Profile-scoped to `omarchy`; depends on `core` and affects systemd networking state.
