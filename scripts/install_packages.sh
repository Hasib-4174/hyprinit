#!/usr/bin/env bash
set -euo pipefail

# ============================
# install_packages.sh
# ============================
# Installs packages listed in packages/*.txt
# - Ignores comments and blank lines
# - Uses pacman for repo packages
# - Uses AUR helper ONLY when needed
# - Never removes or upgrades packages
# ============================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
PACKAGES_DIR="$ROOT_DIR/packages"
VARS_FILE="$ROOT_DIR/vars.conf"

# Load variables
if [[ -f "$VARS_FILE" ]]; then
  source "$VARS_FILE"
else
  echo "[ERROR] vars.conf not found"
  exit 1
fi

AUR_HELPER="${AUR_HELPER:-yay}"

if ! command -v sudo >/dev/null; then
  echo "[ERROR] sudo not available"
  exit 1
fi

# Ensure AUR helper exists if needed
ensure_aur() {
  if command -v "$AUR_HELPER" >/dev/null; then
    return
  fi

  echo "[INFO] Installing AUR helper: $AUR_HELPER"

  sudo pacman -S --needed --noconfirm git base-devel

  cd /tmp
  git clone "https://aur.archlinux.org/${AUR_HELPER}.git"
  cd "$AUR_HELPER"
  makepkg -si --noconfirm
}

install_list() {
  local file="$1"

  echo
  echo "[INFO] Installing from $(basename "$file")"

  mapfile -t pkgs < <(
    grep -Ev '^\s*#|^\s*$' "$file"
  )

  for pkg in "${pkgs[@]}"; do
    if pacman -Qi "$pkg" &>/dev/null; then
      echo "  [SKIP] $pkg already installed"
      continue
    fi

    if pacman -Si "$pkg" &>/dev/null; then
      sudo pacman -S --needed --noconfirm "$pkg"
    else
      ensure_aur
      "$AUR_HELPER" -S --needed --noconfirm "$pkg"
    fi
  done
}

for list in "$PACKAGES_DIR"/*.txt; do
  install_list "$list"
done

echo
echo "[DONE] Package installation complete"
