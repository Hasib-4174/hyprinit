#!/usr/bin/env bash
set -euo pipefail

# ============================
# sanity_check.sh
# ============================
# Checks if essential packages and services are installed and running
# For a fresh Arch + Hyprland minimal setup
# ============================

echo "=============================="
echo " SANITY CHECK FOR HYPRSETUP"
echo "=============================="

# ----------------------------
# Helper functions
# ----------------------------
check_command() {
    local cmd=$1
    local name=$2
    if command -v "$cmd" >/dev/null; then
        echo "[OK] $name found"
    else
        echo "[MISSING] $name NOT found"
    fi
}

check_service() {
    local service=$1
    if systemctl is-active --quiet "$service"; then
        echo "[RUNNING] $service"
    else
        echo "[STOPPED] $service"
    fi
}

echo
echo "-> Checking essential commands..."
check_command git "Git"
check_command yay "AUR Helper (yay)"
check_command alacritty "Alacritty terminal"
check_command foot "Foot terminal"
check_command thunar "Thunar file manager"
check_command rofi "Rofi launcher"
check_command waybar "Waybar status bar"
check_command hyprland "Hyprland compositor"
check_command hyprlock "Hyprlock screen locker"
check_command hypridle "Hypridle daemon"
check_command pipewire "PipeWire audio server"
check_command tailscale "Tailscale VPN"
check_command tmux "TMUX terminal multiplexer"
check_command neovim "Neovim"
check_command wget "wget downloader"
check_command stow "stow for dotfiles"

echo
echo "-> Checking essential systemd services..."
check_service NetworkManager
check_service pipewire
check_service pipewire-pulse
check_service wireplumber

# Optional services
services=("libvirtd" "virtlogd" "tailscale" "bluetooth" "zram-generator")
for s in "${services[@]}"; do
    if systemctl list-unit-files | grep -q "$s"; then
        check_service "$s"
    fi
done

echo
echo "-> Checking Wayland-related binaries..."
check_command mako "Mako notifications"
check_command swww "SWWW wallpaper daemon"
check_command grim "Grim screenshot tool"
check_command swappy "Swappy screenshot editor"
check_command slurp "Slurp region selector"

echo
echo "-> Sanity check complete."
echo "If anything is missing, rerun install_packages.sh or check vars.conf."
