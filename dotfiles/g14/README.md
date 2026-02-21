# G14 Machine-Specific Configuration

Machine-specific dotfiles for ASUS ROG Zephyrus G14.

## Touchpad Auto-Toggle

Automatically disables the touchpad when a Logitech wireless mouse receiver is plugged in, and re-enables it when unplugged.

Uses a hybrid approach: kernel sysfs `inhibited` to disable the touchpad (reliable), plus `hyprctl keyword` to kick Hyprland into re-reading the device on re-enable (workaround for Hyprland 0.53+ bug #7081 where `device[...]:enabled` silently fails to disable).

### Files

- `.local/bin/touchpad-monitor` - Monitor script (sysfs inhibited + hyprctl hybrid)
- `.config/systemd/user/touchpad-monitor.service` - Systemd user service
- `etc/udev/rules.d/99-touchpad-inhibit.rules` - udev rule (reference, requires manual install)

### Setup

After `./dev sync`:

1. Install the udev rule (requires sudo):

```bash
sudo cp ~/personal/dev/dotfiles/g14/etc/udev/rules.d/99-touchpad-inhibit.rules /etc/udev/rules.d/
sudo udevadm control --reload-rules
sudo udevadm trigger --subsystem-match=input --attr-match="name=ASUF1208:00 2808:0218 Touchpad"
```

2. Enable the service:

```bash
systemctl --user daemon-reload
systemctl --user enable --now touchpad-monitor.service
```

### Requirements

- `inotify-tools` package (provides `inotifywait`)
- `jq` package

### Customization

To use a different mouse, edit the script and change the detection pattern:

```bash
# Current: matches any Logitech device
select(.name | test("logitech"; "i"))

# Example: match Razer instead
select(.name | test("razer"; "i"))
```

To use a different touchpad, find your device name with `hyprctl devices` and update the touchpad name in both `find_touchpad_inhibit()` and the `hyprctl keyword` call.

### Management

```bash
systemctl --user status touchpad-monitor   # Check status
systemctl --user stop touchpad-monitor     # Temporarily disable
systemctl --user start touchpad-monitor    # Re-enable
systemctl --user disable touchpad-monitor  # Stop running on boot
```

## GPU Device Symlinks

Creates stable `/dev/dri/amd-igpu` and `/dev/dri/nvidia-dgpu` symlinks for the dual GPU setup (AMD iGPU + NVIDIA dGPU), so applications can reference GPUs by name instead of card number.

### Files

- `etc/udev/rules.d/amd-igpu-dev-path.rules` - AMD iGPU symlink (requires manual install)
- `etc/udev/rules.d/nvidia-dgpu-dev-path.rules` - NVIDIA dGPU symlink (requires manual install)

### Setup

```bash
sudo cp ~/personal/dev/dotfiles/g14/etc/udev/rules.d/amd-igpu-dev-path.rules /etc/udev/rules.d/
sudo cp ~/personal/dev/dotfiles/g14/etc/udev/rules.d/nvidia-dgpu-dev-path.rules /etc/udev/rules.d/
sudo udevadm control --reload-rules
sudo udevadm trigger
```

## Power Saver

Script to toggle between battery and AC power profiles. Manages services (docker, CUPS, nvidia-persistenced), bluetooth, disk write batching, PCI/NVMe power management, and Hyprland eye candy.

### Files

- `.local/bin/power-saver` - Power profile toggle script

### Usage

```bash
power-saver battery   # Switch to battery profile
power-saver ac        # Switch to AC profile
```

### What It Does

**Battery mode:**
- Stops docker, containerd, CUPS, nvidia-persistenced (if safe)
- Disables bluetooth (if nothing connected)
- Enables disk write batching and PCI/NVMe runtime PM
- Disables Hyprland blur and shadows

**AC mode:**
- Starts docker, containerd, nvidia-persistenced
- Re-enables bluetooth
- Restores disk write defaults
- Re-enables Hyprland blur and shadows

### Requirements

- `sudo` access for service management and sysfs writes
- `rfkill` for bluetooth control
