# Windows Desktop Layer

Windows desktop environment configurations, intended for WSL users who want
to manage Windows-side tools from their dotfiles.

## Included Configurations

- **yasb** - Yet Another Status Bar (Windows taskbar replacement)
- **glazewm** - Tiling window manager for Windows

## Usage

Enable in `.local/machine.conf`:

```bash
INCLUDE_WINDOWS=true
```

Then run:

```bash
./dev sync
```

## Note

These configs deploy to `~/.config/` which can be accessed from Windows at
`\\wsl$\<distro>\home\<user>\.config\` or via symlinks to the Windows filesystem.
