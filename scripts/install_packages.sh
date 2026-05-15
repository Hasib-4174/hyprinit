#!/usr/bin/env bash
set -uo pipefail

# ============================
# install_packages.sh
# ============================
# Installs packages listed in packages/*.txt
# - Processes lists in dependency order: base → hypr → apps → dev
# - Ignores comments and blank lines
# - Uses pacman for official repo packages
# - Uses AUR helper only when package is not in official repos
# - Collects failures and reports at end (does not abort on first failure)
# - Never removes or upgrades existing packages
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

# Track failed packages
failed_packages=()

# ----------------------------
# Refresh package database
# ----------------------------
echo "[INFO] Refreshing package database..."
if sudo pacman -Sy --noconfirm 2>/dev/null; then
  echo "  [OK] Package database refreshed"
else
  echo "  [WARN] Failed to refresh package database, continuing with cached data"
fi

# ----------------------------
# Ensure AUR helper exists
# ----------------------------
ensure_aur() {
  if command -v "$AUR_HELPER" >/dev/null; then
    return
  fi

  echo "[INFO] Installing AUR helper: $AUR_HELPER"

  sudo pacman -S --needed --noconfirm git base-devel

  local aur_build_dir="$ROOT_DIR/.aur-build"
  mkdir -p "$aur_build_dir"

  if [[ -d "$aur_build_dir/$AUR_HELPER" ]]; then
    rm -rf "$aur_build_dir/$AUR_HELPER"
  fi

  git clone "https://aur.archlinux.org/${AUR_HELPER}.git" "$aur_build_dir/$AUR_HELPER"
  cd "$aur_build_dir/$AUR_HELPER"
  makepkg -si --noconfirm
  cd "$ROOT_DIR"

  # Cleanup
  rm -rf "$aur_build_dir"
}

# ----------------------------
# Install packages from a list file
# ----------------------------
install_list() {
  local file="$1"

  if [[ ! -f "$file" ]]; then
    echo "[WARN] Package list not found: $file, skipping"
    return
  fi

  echo
  echo "[INFO] Installing from $(basename "$file")"

  mapfile -t pkgs < <(
    grep -Ev '^\s*#|^\s*$' "$file"
  )

  if [[ ${#pkgs[@]} -eq 0 ]]; then
    echo "  [SKIP] No packages in $(basename "$file")"
    return
  fi

  for pkg in "${pkgs[@]}"; do
    # Trim whitespace
    pkg="$(echo "$pkg" | xargs)"

    if [[ -z "$pkg" ]]; then
      continue
    fi

    if pacman -Qi "$pkg" &>/dev/null; then
      echo "  [SKIP] $pkg already installed"
      continue
    fi

    if pacman -Si "$pkg" &>/dev/null 2>&1; then
      if sudo pacman -S --needed --noconfirm "$pkg" 2>/dev/null; then
        echo "  [OK] $pkg installed"
      else
        echo "  [FAIL] $pkg failed to install (pacman)"
        failed_packages+=("$pkg")
      fi
    else
      ensure_aur
      if "$AUR_HELPER" -S --needed --noconfirm "$pkg" 2>/dev/null; then
        echo "  [OK] $pkg installed (AUR)"
      else
        echo "  [FAIL] $pkg failed to install (AUR)"
        failed_packages+=("$pkg")
      fi
    fi
  done
}

# ----------------------------
# Install in dependency order
# ----------------------------
install_order=("base.txt" "hypr.txt" "apps.txt" "dev.txt")

for list_name in "${install_order[@]}"; do
  list_file="$PACKAGES_DIR/$list_name"
  install_list "$list_file"
done

# ----------------------------
# Summary
# ----------------------------
echo
if [[ ${#failed_packages[@]} -gt 0 ]]; then
  echo "[WARN] Package installation completed with ${#failed_packages[@]} failure(s):"
  for pkg in "${failed_packages[@]}"; do
    echo "  - $pkg"
  done
  echo
  echo "You can retry failed packages manually:"
  echo "  sudo pacman -S <package>     # for official repo packages"
  echo "  $AUR_HELPER -S <package>     # for AUR packages"
else
  echo "[DONE] All packages installed successfully"
fi
