# dotfiles/g14/etc/

System-level reference files for the G14 layer.

## Responsibility

Contains files that are meant to be copied into `/etc` on this machine, mainly udev rules.

## Design

Keeps privileged host rules outside the synced home tree while still versioning them in dotfiles.

## Flow

After sync, the user copies selected rules into place and reloads udev so device naming and input policies take effect.

## Integration

Feeds udev on the host and supports the touchpad and GPU-specific behavior described in the G14 README.
