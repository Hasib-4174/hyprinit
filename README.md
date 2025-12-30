<div align="center">

# 🚀 HyprInit

**A minimal, automated Hyprland setup for fresh Arch Linux installations.**

[![Arch Linux](https://img.shields.io/badge/Arch%20Linux-1793D1?style=for-the-badge&logo=arch-linux&logoColor=white)](https://archlinux.org/)
[![Hyprland](https://img.shields.io/badge/Hyprland-58E1FF?style=for-the-badge&logo=wayland&logoColor=black)](https://hyprland.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](LICENSE)

</div>

**HyprInit** provides a complete, ready-to-use configuration for a minimal and functional Arch Linux desktop using the Hyprland compositor. It automates the entire setup process—from installing packages to symlinking configurations with GNU Stow—allowing you to get up and running with a beautiful Hyprland workflow in minutes.

---

## ✨ Features

- **Compositor**: [Hyprland](https://hyprland.org/) - Dynamic tiling Wayland compositor with smooth animations
- **Display Manager**: [SDDM](https://github.com/sddm/sddm) - Modern Qt-based display manager
- **Status Bar**: [Waybar](https://github.com/Alexays/Waybar) - Highly customizable Wayland status bar
- **Application Launcher**: [Rofi](https://github.com/davatorium/rofi) - Versatile application launcher with emoji support
- **Terminal**: [Alacritty](https://alacritty.org/) - Fast, GPU-accelerated terminal emulator
- **File Manager**: [Dolphin](https://apps.kde.org/dolphin/) - Powerful KDE file manager
- **Browser**: [Brave](https://brave.com/) - Privacy-focused Chromium-based browser
- **Editors**: [Neovim](https://neovim.io/) + [VS Code](https://code.visualstudio.com/) - Modern text editing
- **Shell**: [Zsh](https://www.zsh.org/) with [Zinit](https://github.com/zdharma-continuum/zinit) + [Powerlevel10k](https://github.com/romkatv/powerlevel10k)
- **Notifications**: [Mako](https://github.com/emersion/mako) - Lightweight Wayland notification daemon
- **Screenshots**: [Grim](https://sr.ht/~emersion/grim/) + [Slurp](https://github.com/emersion/slurp) + [Swappy](https://github.com/jtheoof/swappy)
- **Wallpapers**: [SWWW](https://github.com/LGFae/swww) - Efficient animated wallpaper daemon
- **Lock Screen**: [Hyprlock](https://github.com/hyprwm/hyprlock) - Secure screen locker for Hyprland
- **Audio**: [PipeWire](https://pipewire.org/) - Modern multimedia framework
- **Fonts**: JetBrains Mono Nerd Font, Noto Fonts, Font Awesome
- **Media**: VLC for video playback
- **Config Management**: [GNU Stow](https://www.gnu.org/software/stow/) - Symlink farm manager for dotfiles

---

## 📸 Screenshots

<!-- Add your screenshots here -->
<!-- ![Desktop](screenshots/desktop.png) -->
<!-- ![Rofi](screenshots/rofi.png) -->
<!-- ![Waybar](screenshots/waybar.png) -->

*Coming soon...*

---

## 🚀 Installation

Setting up your Hyprland environment is simple. The `install.sh` script handles everything automatically.

### Prerequisites

- A **fresh Arch Linux installation** (minimal profile recommended)
- `git` installed
- Active internet connection
- **AMD GPU** (script includes AMD-specific drivers)

> [!WARNING]
> This setup is designed for a **clean Arch Linux installation**. For best results, use a minimal installation without a desktop environment. If using `archinstall`, select the **'minimal' profile**.

### Quick Start

```bash
# Install git if not present
sudo pacman -S git

# Clone the repository
git clone https://github.com/Hasib-4174/hyprinit.git
cd hyprinit

# Make scripts executable
chmod +x install.sh

# Run the installer
./install.sh

# Reboot when complete
sudo reboot
```

### What the Script Does

1. ✅ **Installs AUR helper** (yay) if not present
2. ✅ **Installs all packages** via pacman and AUR
3. ✅ **Copies configs** to `~/configfiles/`
4. ✅ **Symlinks configs** using GNU Stow to `~/.config/`
5. ✅ **Enables services** (NetworkManager, Bluetooth, SDDM, PipeWire)
6. ✅ **Runs verification** to confirm everything is set up

After reboot, SDDM will greet you. Select **Hyprland** from the session dropdown.

---

## 📦 Packages Included

<details>
<summary><b>Core System</b></summary>

- `base`, `base-devel`, `linux`, `linux-firmware`
- `amd-ucode`, `sof-firmware`
- `networkmanager`, `bluez`, `bluez-utils`
- `git`, `wget`, `unzip`, `7zip`, `jq`
- Fonts: `noto-fonts`, `noto-fonts-emoji`, `ttf-jetbrains-mono-nerd`, `otf-font-awesome`

</details>

<details>
<summary><b>Hyprland Stack</b></summary>

- `hyprland`, `hyprpaper`, `hyprlock`, `hypridle`
- `sddm`, `qt5-wayland`, `qt6-wayland`
- `waybar`, `mako`, `wlogout`
- `rofi`, `rofi-emoji`
- `swww`, `grim`, `slurp`, `swappy`
- `wl-clipboard`, `wev`
- `xdg-desktop-portal-hyprland`

</details>

<details>
<summary><b>Audio (PipeWire)</b></summary>

- `pipewire`, `pipewire-alsa`, `pipewire-jack`, `pipewire-pulse`
- `wireplumber`, `gst-plugin-pipewire`, `libpulse`

</details>

<details>
<summary><b>Applications</b></summary>

- `alacritty` - Terminal
- `dolphin` - File manager
- `brave-bin` - Browser
- `vlc` - Media player
- `imv` - Image viewer
- `blueman`, `pavucontrol`, `brightnessctl` - System utilities
- `btop`, `htop`, `fastfetch` - Monitoring

</details>

<details>
<summary><b>Development</b></summary>

- `neovim`, `vim`, `nano`, `visual-studio-code-bin`
- `tmux`, `stow`, `zsh`
- `nodejs`, `npm`, `python-pip`, `ipython`
- `vulkan-radeon`, `xf86-video-amdgpu`, `radeontop` - AMD GPU

</details>

---

## ⌨️ Keybindings

Keybindings are configured in `~/.config/hypr/keybinds.conf`. The main modifier is **ALT**.

### Essential Bindings

| Keybinding | Action |
|------------|--------|
| `Alt + Return` | Open Alacritty (Terminal) |
| `Alt + E` | Open Dolphin (File Manager) |
| `Alt + D` | Open Rofi (App Launcher) |
| `Alt + Q` | Close active window |
| `Alt + M` | Exit Hyprland |
| `Alt + V` | Toggle floating window |
| `Alt + L` | Lock screen (Hyprlock) |
| `Alt + W` | Random wallpaper |
| `Alt + S` | Screenshot |

### Window Navigation (Vim-style)

| Keybinding | Action |
|------------|--------|
| `Alt + H` | Focus left |
| `Alt + J` | Focus down |
| `Alt + K` | Focus up |
| `Alt + L` | Focus right |

### Workspaces

| Keybinding | Action |
|------------|--------|
| `Alt + [1-9, 0]` | Switch to workspace 1-10 |
| `Alt + Shift + [1-9, 0]` | Move window to workspace 1-10 |
| `Alt + S` | Toggle scratchpad |
| `Alt + Shift + S` | Move to scratchpad |
| `Alt + Mouse Wheel` | Scroll through workspaces |

### Media Keys

| Key | Action |
|-----|--------|
| `Volume Up/Down` | Adjust volume |
| `Mute` | Toggle mute |
| `Brightness Up/Down` | Adjust screen brightness |
| `Play/Pause/Next/Prev` | Media controls |

---

## 📂 Configuration Structure

All configurations use **GNU Stow** for symlink management:

```
hyprinit/
├── install.sh              # Main installer
├── vars.conf               # User settings (edit before install)
├── README.md               # This file
│
├── packages/               # Package lists
│   ├── base.txt            # System essentials
│   ├── hypr.txt            # Hyprland stack
│   ├── apps.txt            # Desktop applications
│   └── dev.txt             # Development tools
│
├── config/                 # Stow-compatible configs
│   ├── hypr/               # → ~/.config/hypr/
│   │   └── .config/hypr/
│   │       ├── hyprland.conf
│   │       ├── keybinds.conf
│   │       ├── appearance.conf
│   │       └── ...
│   ├── waybar/             # → ~/.config/waybar/
│   ├── rofi/               # → ~/.config/rofi/
│   ├── alacritty/          # → ~/.config/alacritty/
│   ├── mako/               # → ~/.config/mako/
│   ├── swww/               # → ~/.config/swww/
│   ├── zsh/                # → ~/.zshrc
│   ├── sddm/               # → /etc/sddm.conf.d/
│   └── scripts/            # → ~/.local/bin/
│
└── scripts/                # Installation scripts
    ├── install_packages.sh
    ├── setup_configs.sh
    ├── enable_services.sh
    └── sanity_check.sh
```

### After Installation

Configs are stored in `~/configfiles/` and symlinked to their destinations.

```bash
# Your configs live here:
~/configfiles/
├── hypr/
├── waybar/
├── rofi/
└── ...

# Symlinked to:
~/.config/hypr → ~/configfiles/hypr/.config/hypr
~/.config/waybar → ~/configfiles/waybar/.config/waybar
# etc.
```

**To edit configs**: Modify files in `~/configfiles/` — changes apply immediately!

---

## ⚙️ Configuration

Edit `vars.conf` before running the installer:

```bash
# AUR helper (yay or paru)
AUR_HELPER=yay

# Default shell
DEFAULT_SHELL=zsh

# Service toggles
ENABLE_NETWORKMANAGER=true
ENABLE_BLUETOOTH=true
ENABLE_SDDM=true

# Requires post-install setup (browser auth)
ENABLE_TAILSCALE=false
```

---

## 🔧 Troubleshooting

<details>
<summary><b>SDDM Not Starting</b></summary>

```bash
sudo systemctl enable sddm.service
sudo systemctl start sddm.service
```

</details>

<details>
<summary><b>No Audio</b></summary>

PipeWire uses user services. They start automatically on login. To manually start:

```bash
systemctl --user enable --now pipewire pipewire-pulse wireplumber
```

</details>

<details>
<summary><b>Waybar Not Appearing</b></summary>

```bash
killall waybar
waybar &
```

Or check Hyprland autostart: `~/.config/hypr/autostart.conf`

</details>

<details>
<summary><b>Configs Not Symlinked</b></summary>

Re-run the stow setup:

```bash
cd ~/configfiles
stow --restow --target=$HOME hypr waybar rofi alacritty
```

</details>

<details>
<summary><b>AUR Package Fails</b></summary>

Try installing manually:

```bash
yay -S package-name
```

</details>

---

## 🛠️ Customization Tips

| Component | File to Edit |
|-----------|--------------|
| **Keybindings** | `~/.config/hypr/keybinds.conf` |
| **Appearance** | `~/.config/hypr/appearance.conf` |
| **Waybar modules** | `~/.config/waybar/config.jsonc` |
| **Waybar style** | `~/.config/waybar/style.css` |
| **Rofi theme** | `~/.config/rofi/config.rasi` |
| **Terminal** | `~/.config/alacritty/alacritty.toml` |
| **Shell** | `~/.zshrc` |

---

## 🤝 Contributing

Contributions are welcome! Feel free to:

- 🐛 Report bugs
- 💡 Suggest features
- 🔧 Submit pull requests

---

## 📄 License

This project is open-source and available under the [MIT License](LICENSE).

---

<div align="center">

**Made with ❤️ for the Hyprland community**

</div>
