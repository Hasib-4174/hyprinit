#!/usr/bin/env bash
set -euo pipefail

# ============================
# install.sh
# ============================
# Entry point for Hyprland setup on fresh Arch Linux
#
# This script:
#   1. Loads user variables from vars.conf
#   2. Performs sanity checks (not root, Arch Linux, etc.)
#   3. Installs packages (pacman + AUR)
#   4. Sets up configs using GNU stow
#   5. Enables essential services
#   6. Runs post-install verification
#
# Usage:
#   chmod +x install.sh
#   ./install.sh
#
# Safe to re-run.
# ============================

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
    echo -e "\n${BLUE}==============================${NC}"
    echo -e "${BLUE} $1${NC}"
    echo -e "${BLUE}==============================${NC}\n"
}

print_success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# ----------------------------
# Setup paths
# ----------------------------
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="$ROOT_DIR/scripts"
VARS_FILE="$ROOT_DIR/vars.conf"

# ----------------------------
# Load user variables
# ----------------------------
if [[ ! -f "$VARS_FILE" ]]; then
    print_error "vars.conf not found at $VARS_FILE"
    exit 1
fi

source "$VARS_FILE"
print_success "Loaded configuration from vars.conf"

# ----------------------------
# Sanity checks
# ----------------------------
print_header "PRE-FLIGHT CHECKS"

# Check not running as root
if [[ $EUID -eq 0 ]]; then
    print_error "Do NOT run this script as root!"
    echo "       Run as your normal user. sudo will be used when needed."
    exit 1
fi
print_success "Running as normal user"

# Check Arch Linux
if ! command -v pacman >/dev/null; then
    print_error "pacman not found — this script is for Arch Linux only"
    exit 1
fi
print_success "Arch Linux detected"

# Check sudo
if ! command -v sudo >/dev/null; then
    print_error "sudo is required but not installed"
    echo "       Install with: su -c 'pacman -S sudo'"
    exit 1
fi
print_success "sudo available"

# Check internet connectivity
if ! ping -c 1 archlinux.org &>/dev/null; then
    print_warn "No internet connection detected"
    echo "       Package installation may fail"
else
    print_success "Internet connectivity confirmed"
fi

# ----------------------------
# Step 1: Package installation
# ----------------------------
print_header "STEP 1: INSTALLING PACKAGES"

if [[ -f "$SCRIPTS_DIR/install_packages.sh" ]]; then
    bash "$SCRIPTS_DIR/install_packages.sh"
else
    print_error "install_packages.sh not found!"
    exit 1
fi

# ----------------------------
# Step 2: Config setup
# ----------------------------
print_header "STEP 2: SETTING UP CONFIGS"

if [[ -f "$SCRIPTS_DIR/setup_configs.sh" ]]; then
    bash "$SCRIPTS_DIR/setup_configs.sh"
else
    print_error "setup_configs.sh not found!"
    exit 1
fi

# ----------------------------
# Step 3: Enable services
# ----------------------------
print_header "STEP 3: ENABLING SERVICES"

if [[ -f "$SCRIPTS_DIR/enable_services.sh" ]]; then
    bash "$SCRIPTS_DIR/enable_services.sh"
else
    print_warn "enable_services.sh not found, skipping"
fi

# ----------------------------
# Step 4: Sanity check
# ----------------------------
print_header "STEP 4: POST-INSTALL VERIFICATION"

if [[ -f "$SCRIPTS_DIR/sanity_check.sh" ]]; then
    bash "$SCRIPTS_DIR/sanity_check.sh"
else
    print_warn "sanity_check.sh not found, skipping verification"
fi

# ----------------------------
# Final message
# ----------------------------
print_header "HYPRLAND SETUP COMPLETE!"

echo -e "${GREEN}
╔════════════════════════════════════════════════════════════════╗
║                                                                ║
║   🎉  Hyprland installation completed successfully!  🎉       ║
║                                                                ║
╠════════════════════════════════════════════════════════════════╣
║                                                                ║
║   NEXT STEPS:                                                  ║
║                                                                ║
║   1. REBOOT your system                                        ║
║      sudo reboot                                               ║
║                                                                ║
║   2. SDDM will start automatically                             ║
║      Select 'Hyprland' from the session dropdown               ║
║                                                                ║
║   3. VERIFY everything works:                                  ║
║      - Waybar appears at top                                   ║
║      - Audio (PipeWire) working                                ║
║      - Super+D opens Rofi launcher                             ║
║      - Screenshot: Print key                                   ║
║                                                                ║
╠════════════════════════════════════════════════════════════════╣
║                                                                ║
║   CONFIGURATION:                                               ║
║                                                                ║
║   Configs location:  ~/configfiles/                            ║
║   Symlinked to:      ~/.config/                                ║
║                                                                ║
║   To edit configs, modify files in ~/configfiles/              ║
║   Changes apply immediately (symlinked)                        ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝
${NC}"

echo
echo "Enjoy your new Hyprland setup! 🚀"
echo
