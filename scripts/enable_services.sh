#!/usr/bin/env bash
set -euo pipefail

# ============================
# enable_services.sh
# ============================
# Enables and starts essential services for Hyprland environment
# Safe to re-run multiple times
# ============================

echo "[INFO] Enabling essential system services..."

# ----------------------------
# Network & Wireless
# ----------------------------
echo "  [INFO] NetworkManager"
sudo systemctl enable --now NetworkManager.service

# iwd (optional) – only if you prefer iwd over NetworkManager
# sudo systemctl enable --now iwd.service

# Tailscale (VPN)
if command -v tailscale >/dev/null; then
    echo "  [INFO] Tailscale VPN"
    sudo systemctl enable --now tailscale.service
else
    echo "  [WARN] Tailscale not installed, skipping"
fi

# ----------------------------
# Audio
# ----------------------------
echo "  [INFO] PipeWire and WirePlumber"
sudo systemctl enable --now pipewire.service
sudo systemctl enable --now pipewire-pulse.service
sudo systemctl enable --now wireplumber.service

# ----------------------------
# Virtualization (optional)
# ----------------------------
if command -v libvirtd >/dev/null; then
    echo "  [INFO] libvirt virtualization"
    sudo systemctl enable --now libvirtd.service
    sudo systemctl enable --now virtlogd.service
else
    echo "  [WARN] libvirt not installed, skipping"
fi

# ----------------------------
# Bluetooth (optional)
# ----------------------------
if command -v bluetoothctl >/dev/null; then
    echo "  [INFO] Bluetooth service"
    sudo systemctl enable --now bluetooth.service
else
    echo "  [WARN] Bluetooth not installed, skipping"
fi

# ----------------------------
# zram swap
# ----------------------------
if systemctl list-unit-files | grep -q zram; then
    echo "  [INFO] zram-generator"
    sudo systemctl enable --now zram-generator.service
fi

# ----------------------------
# Notifications (Wayland)
# ----------------------------
# No systemd service needed for mako, swaync, wlogout, etc.
# They are started in autostart via Hyprland config

echo
echo "[DONE] Services enabled and started."
echo "Re-run this script if you install new components."
