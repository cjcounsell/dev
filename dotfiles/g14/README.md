# G14 Machine-Specific Configuration

Machine-specific dotfiles for ASUS ROG Zephyrus G14.

## Touchpad Auto-Toggle

Automatically disables the touchpad when a Logitech wireless mouse receiver is plugged in, and re-enables it when unplugged.

### Files

- `.local/bin/touchpad-monitor` - Monitor script
- `.config/systemd/user/touchpad-monitor.service` - Systemd user service

### Setup

After `./dev sync`, enable the service:

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

To use a different touchpad, find your device name with `hyprctl devices` and update the `TOUCHPAD` variable.

### Management

```bash
systemctl --user status touchpad-monitor   # Check status
systemctl --user stop touchpad-monitor     # Temporarily disable
systemctl --user start touchpad-monitor    # Re-enable
systemctl --user disable touchpad-monitor  # Stop running on boot
```
