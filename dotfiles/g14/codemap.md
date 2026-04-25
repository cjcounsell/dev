# dotfiles/g14/

Machine-specific layer for the ASUS ROG Zephyrus G14.

## Responsibility

Houses laptop-specific power, touchpad, GPU, and Hyprland tweaks that should only apply to this host.

## Design

Separates user-level config from privileged udev rules. Runtime scripts watch hardware state and apply conservative power/device policies.

## Flow

Systemd user services and local scripts react to device changes, then update touchpad inhibition, power profiles, or related desktop settings.

## Integration

Integrates with Hyprland, systemd user services, udev, and `/dev/dri` device naming. Some files are reference-only and require manual install with sudo.
