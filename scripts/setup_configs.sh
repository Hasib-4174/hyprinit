#!/usr/bin/env bash
set -euo pipefail

# ============================
# setup_configs.sh
# ============================
# This script DOES NOT create or modify configuration files.
# It only:
#   - creates required ~/.config directories
#   - optionally symlinks existing user configs
#   - backs up conflicts safely
#
# You are expected to already have your configs elsewhere.
# Example: ~/dotfiles/hypr, ~/dotfiles/waybar, etc.
# ============================

CONFIG_ROOT="$HOME/.config"
DOTFILES_ROOT="${DOTFILES_ROOT:-$HOME/dotfiles}"

# List of config directories Hyprland stack expects
CONFIG_DIRS=(
  hypr
  waybar
  kitty
  mako
  wlogout
  rofi
  swww
)

echo "[INFO] Using dotfiles directory: $DOTFILES_ROOT"
echo

mkdir -p "$CONFIG_ROOT"

for dir in "${CONFIG_DIRS[@]}"; do
  target="$CONFIG_ROOT/$dir"
  source="$DOTFILES_ROOT/$dir"

  echo "[INFO] Processing $dir"

  # If config already exists
  if [[ -e "$target" && ! -L "$target" ]]; then
    backup="${target}.bak.$(date +%Y%m%d-%H%M%S)"
    echo "  [WARN] Existing config found → backing up to $backup"
    mv "$target" "$backup"
  fi

  # If symlink already correct
  if [[ -L "$target" ]]; then
    echo "  [SKIP] Symlink already exists"
    continue
  fi

  # Only symlink if source exists
  if [[ -d "$source" ]]; then
    ln -s "$source" "$target"
    echo "  [OK] Symlinked $dir"
  else
    echo "  [WARN] No source config at $source — skipped"
  fi

done

echo
echo "[DONE] Config setup complete"
echo "Nothing was generated or overwritten."
