<div align="center">

# 🚀 HyprInit

**Automated Hyprland setup for fresh Arch Linux installations.**

[![Arch Linux](https://img.shields.io/badge/Arch%20Linux-1793D1?style=for-the-badge&logo=arch-linux&logoColor=white)](https://archlinux.org/)[![Hyprland](https://img.shields.io/badge/Hyprland-58E1FF?style=for-the-badge&logo=wayland&logoColor=black)](https://hyprland.org/)[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](LICENSE)

</div>

**HyprInit** automates the setup of a complete Hyprland desktop on a fresh Arch Linux installation. It installs packages, clones your dotfiles, deploys configs with GNU Stow, and enables services — getting you from a minimal Arch install to a fully working Wayland desktop in minutes.

> [!IMPORTANT]
> **HyprInit ≠ Dotfiles.** This repository only contains the *installer* — scripts and package lists. Your actual configs (Hyprland, Waybar, Rofi, etc.) live in a separate [dotfiles repository](https://github.com/Hasib-4174/dotfiles), managed with GNU Stow.

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────┐
│                      hyprinit/                          │
│  (this repo — installer only)                           │
│                                                         │
│  install.sh ──► install_packages.sh (pacman + AUR)      │
│             ──► setup_configs.sh    (clone + stow)      │
│             ──► enable_services.sh  (systemd)           │
│             ──► sanity_check.sh     (verification)      │
│                                                         │
│  packages/     Package lists (base, hypr, apps, dev)    │
│  vars.conf     User-configurable settings               │
└─────────────────────────┬───────────────────────────────┘
                          │ git clone
                          ▼
┌─────────────────────────────────────────────────────────┐
│                    ~/dotfiles/                          │
│  (separate repo — your actual configs)                  │
│                                                         │
│  hypr/.config/hypr/          GNU Stow structure         │
│  waybar/.config/waybar/      ──► ~/.config/waybar/      │
│  alacritty/.config/alacritty/──► ~/.config/alacritty/   │
│  rofi/.config/rofi/          ──► ~/.config/rofi/        │
│  nvim/.config/nvim/          ──► ~/.config/nvim/        │
│  zshrc/.zshrc                ──► ~/.zshrc               │
│  ...                                                    │
└─────────────────────────────────────────────────────────┘
```

---

## ✨ What's Included

| Category | Packages |
|----------|----------|
| **Compositor** | [Hyprland](https://hyprland.org/), Hyprpaper, Hyprlock, Hypridle |
| **Display Manager** | SDDM (Qt5/Qt6 Wayland) |
| **Status Bar** | [Waybar](https://github.com/Alexays/Waybar) |
| **Launcher** | [Rofi](https://github.com/davatorium/rofi) + Emoji support |
| **Terminal** | [Alacritty](https://alacritty.org/) |
| **File Manager** | [Dolphin](https://apps.kde.org/dolphin/) |
| **Browser** | [Brave](https://brave.com/) |
| **Editors** | [Neovim](https://neovim.io/), [VS Code](https://code.visualstudio.com/), [Zed](https://zed.dev/) |
| **Shell** | Zsh |
| **Notifications** | [Mako](https://github.com/emersion/mako) |
| **Screenshots** | Grim + Slurp + Swappy |
| **Wallpapers** | [awww](https://github.com/LGFae/awww) (successor to swww) |
| **Lock Screen** | Hyprlock |
| **Audio** | PipeWire + WirePlumber |
| **Media** | VLC, mpv |
| **CLI Tools** | ripgrep, fd, fzf, bat, eza, btop, htop |
| **Containers** | Docker + Docker Compose (optional) |
| **Fonts** | JetBrains Mono Nerd Font, Noto Fonts, Font Awesome |
| **Dotfile Mgmt** | [GNU Stow](https://www.gnu.org/software/stow/) |

---

## 🚀 Installation

### Prerequisites

- A **fresh Arch Linux installation** (minimal profile recommended)
- Active internet connection
- **AMD GPU** (includes AMD-specific drivers; modify for other GPUs)

> [!WARNING]
> This setup is designed for a **clean Arch Linux installation**. For best results, use a minimal installation without a desktop environment. If using `archinstall`, select the **'minimal' profile**.

### Quick Start

```bash
# Install git if not present
sudo pacman -S git

# Clone the installer
git clone https://github.com/Hasib-4174/hyprinit.git
cd hyprinit

# Edit configuration (dotfiles repo URL, service toggles, etc.)
nano vars.conf

# Run the installer
chmod +x install.sh
./install.sh

# Reboot when complete
sudo reboot
```

### Installation Flow

The installer performs these steps in order:

1. **Pre-flight checks** — Verifies: not root, Arch Linux, sudo, git, internet
2. **Install packages** — Installs from `packages/` lists via pacman + AUR helper
   - Order: `base.txt` → `hypr.txt` → `apps.txt` → `dev.txt`
   - Installs AUR helper (yay) automatically if needed
   - Skips already-installed packages
3. **Deploy dotfiles** — Clones your dotfiles repo, stows selected packages
   - If dotfiles already cloned → pulls latest changes
   - Backs up conflicting configs before stowing
4. **Enable services** — NetworkManager, Bluetooth, SDDM, Docker (optional), PipeWire
5. **Verification** — Checks all commands, services, and symlinks

After reboot, SDDM will greet you. Select **Hyprland** from the session dropdown.

---

## 📦 Package Categories

<details>
<summary><b>base.txt — Core System</b></summary>

Core system packages, networking, CLI essentials, fonts, and permissions.

Includes: `base`, `base-devel`, `linux`, `linux-firmware`, `amd-ucode`, `networkmanager`, `bluez`, `git`, `curl`, `wget`, `jq`, `man-db`, `polkit`, `xdg-utils`, Noto/JetBrains Mono fonts.

</details>

<details>
<summary><b>hypr.txt — Hyprland Stack</b></summary>

Full Wayland compositor stack with all essential components.

Includes: `hyprland`, `hyprpaper`, `hyprlock`, `hypridle`, `sddm`, `waybar`, `mako`, `wlogout`, `awww`, `grim`, `slurp`, `swappy`, `wl-clipboard`, `xdg-desktop-portal-hyprland`, `xdg-desktop-portal-gtk`, PipeWire audio stack.

</details>

<details>
<summary><b>apps.txt — Desktop Applications</b></summary>

Daily-use desktop applications.

Includes: `alacritty`, `dolphin`, `brave-bin` (AUR), `rofi`, `rofi-emoji`, `vlc`, `mpv`, `imv`, `blueman`, `pavucontrol`, `brightnessctl`, `btop`, `htop`, `fastfetch`.

</details>

<details>
<summary><b>dev.txt — Development Tools</b></summary>

Development environment with editors, toolchains, and modern CLI tools.

Includes: `neovim`, `vim`, `nano`, `visual-studio-code-bin` (AUR), `zed`, `tmux`, `stow`, `zsh`, `ripgrep`, `fd`, `fzf`, `bat`, `eza`, `nodejs`, `npm`, `python`, `gcc`, `cmake`, `docker`, `docker-compose`, AMD GPU tools (`vulkan-radeon`, `mesa`).

</details>

---

## ⚙️ Configuration

Edit `vars.conf` **before** running the installer:

```bash
# Dotfiles repo (your separate config repository)
DOTFILES_REPO="https://github.com/Hasib-4174/dotfiles.git"
DOTFILES_DIR="$HOME/dotfiles"

# Which stow packages to deploy
STOW_PACKAGES="alacritty awww fontconfig hypr mako nano nvim rofi scripts swappy waybar zshrc"

# AUR helper
AUR_HELPER=yay

# Service toggles
ENABLE_NETWORKMANAGER=true
ENABLE_BLUETOOTH=true
ENABLE_SDDM=true
ENABLE_DOCKER=false
ENABLE_TAILSCALE=false
```

---

## 📂 Repository Structure

```
hyprinit/
├── install.sh              # Main entry point
├── vars.conf               # User configuration
├── README.md               # This file
│
├── packages/               # Package lists (one per category)
│   ├── base.txt            # System essentials
│   ├── hypr.txt            # Hyprland + Wayland stack
│   ├── apps.txt            # Desktop applications
│   └── dev.txt             # Development tools
│
└── scripts/                # Installation scripts
    ├── install_packages.sh # Package installation (pacman + AUR)
    ├── setup_configs.sh    # Dotfiles clone + GNU Stow deployment
    ├── enable_services.sh  # systemd service enablement
    └── sanity_check.sh     # Post-install verification
```

### After Installation

Configs live in `~/dotfiles/` and are symlinked via GNU Stow:

```bash
~/dotfiles/
├── hypr/.config/hypr/          → ~/.config/hypr/
├── waybar/.config/waybar/      → ~/.config/waybar/
├── rofi/.config/rofi/          → ~/.config/rofi/
├── alacritty/.config/alacritty/→ ~/.config/alacritty/
├── nvim/.config/nvim/          → ~/.config/nvim/
├── zshrc/.zshrc                → ~/.zshrc
└── ...
```

**To edit configs**: Modify files in `~/dotfiles/` — changes apply immediately!

---

## 🔗 GNU Stow Usage

GNU Stow creates symlinks from your dotfiles repo to the correct locations in `$HOME`.

```bash
cd ~/dotfiles

# Stow a package (create symlinks)
stow --target=$HOME hypr

# Re-stow (refresh symlinks)
stow --restow --target=$HOME waybar

# Unstow (remove symlinks)
stow -D rofi

# Stow all packages at once
stow --restow --target=$HOME alacritty awww hypr mako nvim rofi waybar zshrc
```

### How Stow Works

```
~/dotfiles/hypr/.config/hypr/hyprland.conf
    ↓ stow
~/.config/hypr/hyprland.conf  (symlink → ~/dotfiles/hypr/.config/hypr/hyprland.conf)
```

Each directory in `~/dotfiles/` is a "stow package." Stow mirrors its internal structure relative to the target directory (`$HOME`).

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

PipeWire uses user services (socket-activated on login):

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
<summary><b>Stow Conflicts</b></summary>

If stow reports conflicts, the target file already exists and is not a symlink:

```bash
# Option 1: Backup and re-stow
mv ~/.config/hypr ~/.config/hypr.bak
cd ~/dotfiles && stow --restow hypr

# Option 2: Adopt existing files into stow (overwrites dotfiles repo)
cd ~/dotfiles && stow --adopt --restow hypr
# WARNING: --adopt replaces dotfiles repo content with existing files
```

</details>

<details>
<summary><b>AUR Package Fails</b></summary>

```bash
# Retry manually
yay -S package-name

# Or rebuild from clean state
yay -S --rebuild package-name
```

</details>

<details>
<summary><b>Dotfiles Repo Not Cloning</b></summary>

```bash
# Check the URL in vars.conf
grep DOTFILES_REPO vars.conf

# Try cloning manually
git clone https://github.com/Hasib-4174/dotfiles.git ~/dotfiles
```

</details>

---

## ⚠️ Important Notes

- **AMD GPU only**: The default package lists include AMD-specific drivers. For Intel or NVIDIA, modify `dev.txt` accordingly.
- **Fresh installs**: This installer is designed for clean Arch Linux systems. Using it on an existing desktop may cause conflicts.
- **Re-runnable**: The installer is idempotent — safe to run multiple times. Already-installed packages are skipped, existing dotfiles are backed up.
- **No destructive operations**: The installer never removes packages or deletes user files. Conflicts are backed up to `~/.config-backups/`.
- **AUR packages**: Only `brave-bin` and `visual-studio-code-bin` require AUR. Everything else is from official repos.

---

## 🛠️ Post-Install Customization

| Component | Config Location |
|-----------|----------------|
| **Hyprland** | `~/dotfiles/hypr/.config/hypr/` |
| **Waybar** | `~/dotfiles/waybar/.config/waybar/` |
| **Rofi** | `~/dotfiles/rofi/.config/rofi/` |
| **Alacritty** | `~/dotfiles/alacritty/.config/alacritty/` |
| **Neovim** | `~/dotfiles/nvim/.config/nvim/` |
| **Mako** | `~/dotfiles/mako/.config/mako/` |
| **Zsh** | `~/dotfiles/zshrc/.zshrc` |

All paths are symlinked — editing files in `~/dotfiles/` directly updates the active config.

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
