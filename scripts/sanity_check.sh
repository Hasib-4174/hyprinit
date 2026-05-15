#!/usr/bin/env bash
set -euo pipefail

# ============================
# sanity_check.sh
# ============================
# Verifies essential packages and services are installed and running
# Run this after installation to confirm everything is set up correctly
# ============================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
VARS_FILE="$ROOT_DIR/vars.conf"

# Load variables for dynamic checks
if [[ -f "$VARS_FILE" ]]; then
    source "$VARS_FILE"
fi

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
ENABLE_DOCKER="${ENABLE_DOCKER:-false}"

echo "=============================="
echo " POST-INSTALL SANITY CHECK"
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
check_command curl "curl"
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
check_command awww "awww wallpaper daemon"
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
check_command zed "Zed editor"
check_command tmux "Tmux"
echo

# ----------------------------
# Modern CLI Tools
# ----------------------------
echo "-> Modern CLI Tools"
check_command rg "ripgrep"
check_command fd "fd"
check_command fzf "fzf"
check_command bat "bat"
check_command eza "eza"
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
check_command vlc "VLC media player"
check_command mpv "mpv media player"
echo

# ----------------------------
# Containers
# ----------------------------
if [[ "$ENABLE_DOCKER" == "true" ]]; then
    echo "-> Containers"
    check_command docker "Docker"
    check_command docker-compose "Docker Compose"
    echo
fi

# ----------------------------
# System Services
# ----------------------------
echo "-> System Services"
check_service "NetworkManager"
check_service "bluetooth"
check_service "sddm"
if [[ "$ENABLE_DOCKER" == "true" ]]; then
    check_service "docker"
fi
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
# Dotfiles & Config Verification
# ----------------------------
echo "-> Dotfiles Repository"
if [[ -d "$DOTFILES_DIR" ]]; then
    if [[ -d "$DOTFILES_DIR/.git" ]]; then
        echo "  [OK] Dotfiles repo exists at $DOTFILES_DIR"
    else
        echo "  [WARN] $DOTFILES_DIR exists but is not a git repo"
    fi
else
    echo "  [MISSING] Dotfiles directory: $DOTFILES_DIR"
fi
echo

echo "-> Config Symlinks"
config_dirs=("hypr" "waybar" "rofi" "mako" "alacritty" "nvim" "swappy" "awww" "fontconfig" "nano")
for dir in "${config_dirs[@]}"; do
    target="$HOME/.config/$dir"
    if [[ -L "$target" ]]; then
        echo "  [LINKED] ~/.config/$dir"
    elif [[ -d "$target" ]]; then
        echo "  [EXISTS] ~/.config/$dir (not a symlink — may need restow)"
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
echo "  2. Dotfiles deployment (re-run setup_configs.sh)"
echo "  3. Service enablement (re-run enable_services.sh)"
echo
echo "To re-stow a specific config:"
echo "  cd $DOTFILES_DIR && stow --restow <package>"
