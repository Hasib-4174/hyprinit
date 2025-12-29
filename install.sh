#!/usr/bin/env bash
set -euo pipefail

# ============================
# install.sh
# ============================
# Entry point for hyprsetup
#
# This script:
#   1. Loads user variables
#   2. Performs sanity checks
#   3. Installs packages
#   4. Sets up configs (NO generation)
#   5. Enables services (opt-in only)
#
# Safe to re-run.
# ============================

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="$ROOT_DIR/scripts"
VARS_FILE="$ROOT_DIR/vars.conf"

# ----------------------------
# Load user variables
# ----------------------------
if [[ ! -f "$VARS_FILE" ]]; then
  echo "[ERROR] vars.conf not found"
  exit 1
fi

source "$VARS_FILE"

# ----------------------------
# Basic sanity checks
# ----------------------------
echo "[INFO] Running sanity checks..."

if [[ $EUID -eq 0 ]]; then
  echo "[ERROR] Do NOT run this script as root"
  exit 1
fi

if ! command -v pacman >/dev/null; then
  echo "[ERROR] pacman not found — this is not Arch Linux"
  exit 1
fi

if ! command -v sudo >/dev/null; then
  echo "[ERROR] sudo is required"
  exit 1
fi

# ----------------------------
# Step 1: Package installation
# ----------------------------
echo
echo "=============================="
echo " STEP 1: INSTALL PACKAGES"
echo "=============================="

bash "$SCRIPTS_DIR/install_packages.sh"

# ----------------------------
# Step 2: Config preparation
# ----------------------------
echo
echo "=============================="
echo " STEP 2: SETUP CONFIGS"
echo "=============================="

bash "$SCRIPTS_DIR/setup_configs.sh"

# ----------------------------
# Step 3: Enable services
# ----------------------------
echo
echo "=============================="
echo " STEP 3: ENABLE SERVICES"
echo "=============================="

if [[ -f "$SCRIPTS_DIR/enable_services.sh" ]]; then
  bash "$SCRIPTS_DIR/enable_services.sh"
else
  echo "[SKIP] enable_services.sh not present"
fi

echo
echo "=============================="
echo " STEP 4: RUN SANITY CHECK"
echo "=============================="
echo "[INFO] Running post-install sanity check..."
bash "$SCRIPTS_DIR/sanity_check.sh"

# ----------------------------
# Final message
# ----------------------------
echo
echo "=============================="
echo " HYPRSETUP COMPLETE"
echo "=============================="
echo
echo "Next steps:"
echo "  - Log out and log into Hyprland"
echo "  - Verify waybar, audio, clipboard"
echo "  - Adjust vars.conf as needed"
echo
echo "Nothing was overwritten."
