# dotfiles/g14/etc/udev/

Udev rule staging area for the G14 host.

## Responsibility

Groups hardware event rules that affect input devices and GPU device paths.

## Design

Rules are versioned here but installed manually, keeping host-only privileged configuration explicit.

## Flow

When copied to `/etc/udev/rules.d`, udev applies the rules on device add/remove or at boot triggers.

## Integration

Connects to the touchpad monitor workflow and stable GPU symlink setup documented in the machine README.
