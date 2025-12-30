#!/usr/bin/env bash
set -euo pipefail

# ============================
# setup_configs.sh
# ============================
# This script:
#   1. Creates ~/configfiles directory
#   2. Copies all config folders from repo's config/ to ~/configfiles
#   3. Uses GNU stow to symlink configs to appropriate locations
#
# The config/ directory in the repo uses stow format:
#   - config/hypr/.config/hypr/  -> stowed to ~/.config/hypr/
#   - config/zsh/.zshrc          -> stowed to ~/.zshrc
#
# Safe to re-run. Existing configs are backed up.
# ============================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
CONFIG_SOURCE="$ROOT_DIR/config"
CONFIG_TARGET="$HOME/configfiles"

# ----------------------------
# Pre-flight checks
# ----------------------------
if [[ ! -d "$CONFIG_SOURCE" ]]; then
    echo "[ERROR] Config source directory not found: $CONFIG_SOURCE"
    exit 1
fi

if ! command -v stow >/dev/null; then
    echo "[ERROR] GNU stow is not installed. Please install it first."
    exit 1
fi

# ----------------------------
# Step 1: Create configfiles directory
# ----------------------------
echo "[INFO] Setting up config directory: $CONFIG_TARGET"

if [[ ! -d "$CONFIG_TARGET" ]]; then
    mkdir -p "$CONFIG_TARGET"
    echo "  [OK] Created $CONFIG_TARGET"
else
    echo "  [OK] $CONFIG_TARGET already exists"
fi

# ----------------------------
# Step 2: Copy configs from repo to ~/configfiles
# ----------------------------
echo
echo "[INFO] Copying configs from repo to $CONFIG_TARGET..."

# Get list of all config packages (directories in config/)
mapfile -t packages < <(find "$CONFIG_SOURCE" -mindepth 1 -maxdepth 1 -type d -printf '%f\n')

for pkg in "${packages[@]}"; do
    src="$CONFIG_SOURCE/$pkg"
    dest="$CONFIG_TARGET/$pkg"
    
    echo "  [INFO] Processing: $pkg"
    
    # If destination exists, back it up
    if [[ -d "$dest" ]]; then
        backup="${dest}.bak.$(date +%Y%m%d-%H%M%S)"
        echo "    [WARN] Existing config found -> backing up to $backup"
        mv "$dest" "$backup"
    fi
    
    # Copy the config package
    cp -r "$src" "$dest"
    echo "    [OK] Copied $pkg"
done

# Handle standalone files (like .zshrc if it exists at root level)
if [[ -f "$CONFIG_SOURCE/.zshrc" ]]; then
    echo "  [INFO] Processing: .zshrc (standalone file)"
    
    # Create a zsh stow package for .zshrc
    zsh_pkg="$CONFIG_TARGET/zsh"
    mkdir -p "$zsh_pkg"
    cp "$CONFIG_SOURCE/.zshrc" "$zsh_pkg/.zshrc"
    echo "    [OK] Created zsh package with .zshrc"
fi

# ----------------------------
# Step 3: Ensure ~/.config exists
# ----------------------------
echo
echo "[INFO] Ensuring ~/.config directory exists..."
mkdir -p "$HOME/.config"

# ----------------------------
# Step 4: Use stow to symlink configs
# ----------------------------
echo
echo "[INFO] Using stow to symlink configs..."

cd "$CONFIG_TARGET"

for pkg in */; do
    pkg="${pkg%/}"  # Remove trailing slash
    echo "  [INFO] Stowing: $pkg"
    
    # Use --restow to handle re-runs gracefully
    # Use --adopt to handle existing files (moves them into stow package)
    if stow --restow --target="$HOME" "$pkg" 2>/dev/null; then
        echo "    [OK] Stowed $pkg"
    else
        # Try with --adopt if there are conflicts
        echo "    [WARN] Conflict detected, attempting to adopt existing files..."
        if stow --adopt --restow --target="$HOME" "$pkg"; then
            echo "    [OK] Stowed $pkg (adopted existing files)"
        else
            echo "    [ERROR] Failed to stow $pkg"
        fi
    fi
done

# ----------------------------
# Done
# ----------------------------
echo
echo "[DONE] Config setup complete!"
echo
echo "Configs copied to: $CONFIG_TARGET"
echo "Symlinks created in: $HOME and $HOME/.config"
echo
echo "To manually re-stow a package, run:"
echo "  cd $CONFIG_TARGET && stow --restow <package>"
