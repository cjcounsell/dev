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
