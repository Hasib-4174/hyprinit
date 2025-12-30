# Hyprland Setup Automation (hyprinit)

Automated Hyprland installation for fresh Arch Linux systems.

## Quick Start

```bash
# On fresh Arch Linux with internet access:
sudo pacman -S git
git clone <repo-url> hyprinit
cd hyprinit
chmod +x install.sh
./install.sh
sudo reboot
```

## What Gets Installed

### Core Stack
- **Hyprland** - Wayland compositor
- **SDDM** - Display manager
- **Waybar** - Status bar
- **Rofi** - Application launcher
- **Mako** - Notifications
- **PipeWire** - Audio

### Applications
- **Alacritty** - Terminal
- **Brave** - Browser
- **Dolphin** - File manager
- **Neovim/VSCode** - Editors

### Development
- Node.js, Python, Zsh

## Configuration

Edit `vars.conf` before running:

```bash
# Enable/disable services
ENABLE_NETWORKMANAGER=true
ENABLE_BLUETOOTH=true
ENABLE_SDDM=true
ENABLE_TAILSCALE=false  # Requires post-install auth
```

## Structure

```
hyprinit/
├── install.sh          # Entry point
├── vars.conf           # User settings
├── packages/           # Package lists
│   ├── base.txt        # System essentials
│   ├── hypr.txt        # Hyprland stack
│   ├── apps.txt        # Desktop apps
│   └── dev.txt         # Dev tools
├── config/             # Stow-compatible configs
│   ├── hypr/           # Hyprland
│   ├── waybar/         # Status bar
│   ├── rofi/           # Launcher
│   └── ...
└── scripts/            # Installation scripts
```

## Post-Install

Configs are stored in `~/configfiles/` and symlinked to `~/.config/`.

To modify configs, edit files in `~/configfiles/` - changes apply immediately.

## License

MIT
