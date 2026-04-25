# dotfiles/g14/etc/udev/rules.d/

Concrete udev rule files for host-specific device behavior.

## Responsibility

Defines the actual rules that will be installed on the laptop for touchpad inhibition and GPU path aliases.

## Design

Rules are small, declarative, and intentionally separate from scripts so kernel/device policy stays readable.

## Flow

udev matches device events against these rules and creates symlinks or changes device state accordingly.

## Integration

Consumed by udev after manual copy into `/etc/udev/rules.d`; supports G14-specific input and GPU management.
