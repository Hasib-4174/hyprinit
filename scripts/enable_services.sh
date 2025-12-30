#!/usr/bin/env bash
set -euo pipefail

# ============================
# enable_services.sh
# ============================
# Enables essential systemd services for Hyprland environment
# Respects toggles from vars.conf
# Safe to re-run multiple times
# ============================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
VARS_FILE="$ROOT_DIR/vars.conf"

# Load variables
if [[ -f "$VARS_FILE" ]]; then
    source "$VARS_FILE"
else
    echo "[WARN] vars.conf not found, using defaults"
fi

# Set defaults if not defined
ENABLE_NETWORKMANAGER="${ENABLE_NETWORKMANAGER:-true}"
ENABLE_BLUETOOTH="${ENABLE_BLUETOOTH:-true}"
ENABLE_SDDM="${ENABLE_SDDM:-true}"
ENABLE_TAILSCALE="${ENABLE_TAILSCALE:-false}"

echo "[INFO] Enabling system services..."
echo

# ----------------------------
# Helper function
# ----------------------------
enable_system_service() {
    local service="$1"
    local desc="$2"
    
    echo "  [INFO] $desc ($service)"
    if systemctl list-unit-files | grep -q "^$service"; then
        sudo systemctl enable --now "$service" 2>/dev/null || true
        echo "    [OK] Enabled"
    else
        echo "    [SKIP] Service not found"
    fi
}

# ----------------------------
# NetworkManager
# ----------------------------
if [[ "$ENABLE_NETWORKMANAGER" == "true" ]]; then
    enable_system_service "NetworkManager.service" "NetworkManager"
fi

# ----------------------------
# Bluetooth
# ----------------------------
if [[ "$ENABLE_BLUETOOTH" == "true" ]]; then
    enable_system_service "bluetooth.service" "Bluetooth"
fi

# ----------------------------
# SDDM Display Manager
# ----------------------------
if [[ "$ENABLE_SDDM" == "true" ]]; then
    echo "  [INFO] SDDM Display Manager"
    if command -v sddm >/dev/null; then
        sudo systemctl enable sddm.service
        echo "    [OK] SDDM enabled (will start on reboot)"
    else
        echo "    [SKIP] SDDM not installed"
    fi
fi

# ----------------------------
# PipeWire (User Services)
# ----------------------------
# NOTE: PipeWire runs as user services, not system services
# They are socket-activated and start automatically on login
echo
echo "  [INFO] PipeWire Audio Stack"
echo "    [NOTE] PipeWire uses user services (socket-activated)"
echo "    [NOTE] Will start automatically when you log into Hyprland"

# Enable user services if running in a user session
if [[ -n "${XDG_RUNTIME_DIR:-}" ]]; then
    systemctl --user enable --now pipewire.socket 2>/dev/null || true
    systemctl --user enable --now pipewire-pulse.socket 2>/dev/null || true
    systemctl --user enable --now wireplumber.service 2>/dev/null || true
    echo "    [OK] User services enabled"
else
    echo "    [SKIP] Not in a user session, services will start on first login"
fi

# ----------------------------
# Tailscale (Requires User Action)
# ----------------------------
echo
if [[ "$ENABLE_TAILSCALE" == "true" ]]; then
    if command -v tailscale >/dev/null; then
        enable_system_service "tailscaled.service" "Tailscale Daemon"
        echo
        echo "    ╔════════════════════════════════════════════════════════════╗"
        echo "    ║  TAILSCALE REQUIRES ADDITIONAL SETUP                       ║"
        echo "    ║                                                            ║"
        echo "    ║  After installation, run:                                  ║"
        echo "    ║    tailscale up                                            ║"
        echo "    ║                                                            ║"
        echo "    ║  This will open a browser for authentication.              ║"
        echo "    ╚════════════════════════════════════════════════════════════╝"
        echo
    fi
else
    echo "  [SKIP] Tailscale (disabled in vars.conf)"
    echo "    [INFO] Enable ENABLE_TAILSCALE=true and re-run if needed"
fi

# ----------------------------
# Done
# ----------------------------
echo
echo "[DONE] Service setup complete!"
echo
echo "Services that require reboot to take effect:"
echo "  - SDDM (display manager)"
echo
echo "Services that start on login:"
echo "  - PipeWire (audio)"
echo "  - WirePlumber (audio session manager)"
