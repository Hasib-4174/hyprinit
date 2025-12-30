#!/usr/bin/env bash
set -euo pipefail

# ============================
# sanity_check.sh
# ============================
# Verifies essential packages and services are installed and running
# Run this after installation to confirm everything is set up correctly
# ============================

echo "=============================="
echo " SANITY CHECK FOR HYPRSETUP"
echo "=============================="
echo

# ----------------------------
# Helper functions
# ----------------------------
check_command() {
    local cmd=$1
    local name=$2
    if command -v "$cmd" >/dev/null; then
        echo "  [OK] $name"
    else
        echo "  [MISSING] $name"
    fi
}

check_service() {
    local service=$1
    if systemctl is-active --quiet "$service" 2>/dev/null; then
        echo "  [RUNNING] $service"
    elif systemctl is-enabled --quiet "$service" 2>/dev/null; then
        echo "  [ENABLED] $service (will start on boot/login)"
    else
        echo "  [STOPPED] $service"
    fi
}

check_user_service() {
    local service=$1
    if systemctl --user is-active --quiet "$service" 2>/dev/null; then
        echo "  [RUNNING] $service (user)"
    elif systemctl --user is-enabled --quiet "$service" 2>/dev/null; then
        echo "  [ENABLED] $service (user, socket-activated)"
    else
        echo "  [NOT ACTIVE] $service (user)"
    fi
}

# ----------------------------
# Core System
# ----------------------------
echo "-> Core System Commands"
check_command git "Git"
check_command yay "AUR Helper (yay)"
check_command zsh "Zsh shell"
check_command stow "GNU Stow"
echo

# ----------------------------
# Hyprland Stack
# ----------------------------
echo "-> Hyprland Compositor Stack"
check_command hyprland "Hyprland compositor"
check_command hyprlock "Hyprlock screen locker"
check_command hypridle "Hypridle daemon"
check_command hyprpaper "Hyprpaper wallpaper"
echo

# ----------------------------
# Wayland Tools
# ----------------------------
echo "-> Wayland Utilities"
check_command waybar "Waybar status bar"
check_command rofi "Rofi launcher"
check_command mako "Mako notifications"
check_command wlogout "Wlogout menu"
check_command swww "SWWW wallpaper daemon"
check_command grim "Grim screenshot"
check_command slurp "Slurp region selector"
check_command swappy "Swappy screenshot editor"
check_command wl-copy "wl-clipboard"
echo

# ----------------------------
# Terminal & Editors
# ----------------------------
echo "-> Terminal & Editors"
check_command alacritty "Alacritty terminal"
check_command nvim "Neovim"
check_command vim "Vim"
check_command nano "Nano"
check_command code "VS Code"
check_command tmux "Tmux"
echo

# ----------------------------
# Desktop Apps
# ----------------------------
echo "-> Desktop Applications"
check_command brave "Brave browser"
check_command dolphin "Dolphin file manager"
check_command pavucontrol "PulseAudio Volume Control"
check_command blueman-manager "Blueman Bluetooth"
check_command brightnessctl "Brightness control"
echo

# ----------------------------
# System Services
# ----------------------------
echo "-> System Services"
check_service "NetworkManager"
check_service "bluetooth"
check_service "sddm"
echo

# ----------------------------
# User Services (PipeWire)
# ----------------------------
echo "-> Audio Services (User)"
if [[ -n "${XDG_RUNTIME_DIR:-}" ]]; then
    check_user_service "pipewire"
    check_user_service "pipewire-pulse"
    check_user_service "wireplumber"
else
    echo "  [INFO] Not in user session, cannot check user services"
fi
echo

# ----------------------------
# Config Verification
# ----------------------------
echo "-> Config Symlinks"
config_dirs=("hypr" "waybar" "rofi" "mako" "alacritty")
for dir in "${config_dirs[@]}"; do
    target="$HOME/.config/$dir"
    if [[ -L "$target" ]]; then
        echo "  [LINKED] ~/.config/$dir"
    elif [[ -d "$target" ]]; then
        echo "  [EXISTS] ~/.config/$dir (not a symlink)"
    else
        echo "  [MISSING] ~/.config/$dir"
    fi
done

if [[ -L "$HOME/.zshrc" ]]; then
    echo "  [LINKED] ~/.zshrc"
elif [[ -f "$HOME/.zshrc" ]]; then
    echo "  [EXISTS] ~/.zshrc (not a symlink)"
else
    echo "  [MISSING] ~/.zshrc"
fi
echo

# ----------------------------
# Summary
# ----------------------------
echo "=============================="
echo " SANITY CHECK COMPLETE"
echo "=============================="
echo
echo "If anything is marked [MISSING], check:"
echo "  1. Package installation (re-run install_packages.sh)"
echo "  2. Config setup (re-run setup_configs.sh)"
echo "  3. Service enablement (re-run enable_services.sh)"
