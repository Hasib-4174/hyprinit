#!/usr/bin/env bash
set -euo pipefail

# ============================
# setup_configs.sh
# ============================
# This script:
#   1. Clones the dotfiles repository (or pulls updates)
#   2. Uses GNU Stow to symlink configs to $HOME
#
# The dotfiles repo uses GNU Stow structure:
#   hypr/.config/hypr/     → stowed to ~/.config/hypr/
#   waybar/.config/waybar/ → stowed to ~/.config/waybar/
#   zshrc/.zshrc           → stowed to ~/.zshrc
#
# Safe to re-run. Existing conflicts are backed up.
# ============================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
VARS_FILE="$ROOT_DIR/vars.conf"

# ----------------------------
# Load variables
# ----------------------------
if [[ -f "$VARS_FILE" ]]; then
    source "$VARS_FILE"
else
    echo "[ERROR] vars.conf not found at $VARS_FILE"
    exit 1
fi

# Defaults
DOTFILES_REPO="${DOTFILES_REPO:-}"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
STOW_PACKAGES="${STOW_PACKAGES:-}"

if [[ -z "$DOTFILES_REPO" ]]; then
    echo "[ERROR] DOTFILES_REPO is not set in vars.conf"
    exit 1
fi

if [[ -z "$STOW_PACKAGES" ]]; then
    echo "[ERROR] STOW_PACKAGES is not set in vars.conf"
    exit 1
fi

# ----------------------------
# Pre-flight checks
# ----------------------------
if ! command -v git >/dev/null; then
    echo "[ERROR] git is not installed"
    exit 1
fi

if ! command -v stow >/dev/null; then
    echo "[ERROR] GNU stow is not installed. Install it with: sudo pacman -S stow"
    exit 1
fi

# ----------------------------
# Step 1: Clone or update dotfiles repo
# ----------------------------
echo "[INFO] Setting up dotfiles from: $DOTFILES_REPO"
echo "       Target directory: $DOTFILES_DIR"
echo

if [[ -d "$DOTFILES_DIR" ]]; then
    if [[ -d "$DOTFILES_DIR/.git" ]]; then
        echo "  [INFO] Dotfiles repo already exists, pulling latest changes..."
        if git -C "$DOTFILES_DIR" pull --ff-only 2>/dev/null; then
            echo "  [OK] Updated dotfiles repo"
        else
            echo "  [WARN] Could not fast-forward pull. You may have local changes."
            echo "         Continuing with existing dotfiles."
        fi
    else
        echo "  [ERROR] $DOTFILES_DIR exists but is not a git repository."
        echo "          Please remove or rename it manually, then re-run."
        echo "          Example: mv $DOTFILES_DIR ${DOTFILES_DIR}.bak"
        exit 1
    fi
else
    echo "  [INFO] Cloning dotfiles repo..."
    if git clone "$DOTFILES_REPO" "$DOTFILES_DIR"; then
        echo "  [OK] Cloned dotfiles repo to $DOTFILES_DIR"
    else
        echo "  [ERROR] Failed to clone dotfiles repo"
        echo "         Check your internet connection and the repo URL in vars.conf"
        exit 1
    fi
fi

# ----------------------------
# Step 2: Ensure target directories exist
# ----------------------------
echo
echo "[INFO] Ensuring target directories exist..."
mkdir -p "$HOME/.config"
mkdir -p "$HOME/.local/bin"
echo "  [OK] ~/.config and ~/.local/bin ready"

# ----------------------------
# Step 3: Stow packages
# ----------------------------
echo
echo "[INFO] Stowing dotfile packages..."

# Track results
stow_ok=()
stow_skip=()
stow_fail=()

cd "$DOTFILES_DIR"

for pkg in $STOW_PACKAGES; do
    # Check if the package directory exists in the dotfiles repo
    if [[ ! -d "$DOTFILES_DIR/$pkg" ]]; then
        echo "  [SKIP] $pkg (not found in dotfiles repo)"
        stow_skip+=("$pkg")
        continue
    fi

    echo "  [INFO] Stowing: $pkg"

    # Try stow --restow first (handles idempotent re-runs)
    if stow --restow --target="$HOME" "$pkg" 2>/dev/null; then
        echo "    [OK] Stowed $pkg"
        stow_ok+=("$pkg")
    else
        # Conflict detected — attempt backup and retry
        echo "    [WARN] Conflict detected for $pkg, backing up conflicting files..."

        # Find what stow would create, and backup existing files
        backup_dir="$HOME/.config-backups/$(date +%Y%m%d-%H%M%S)"
        conflict_resolved=true

        # Get the list of files stow wants to create
        stow_output=$(stow --restow --target="$HOME" "$pkg" 2>&1 || true)

        # Extract conflicting file paths from stow error output
        while IFS= read -r line; do
            if [[ "$line" =~ existing\ target.*:\ (.+) ]]; then
                conflict_file="$HOME/${BASH_REMATCH[1]}"
                if [[ -e "$conflict_file" && ! -L "$conflict_file" ]]; then
                    mkdir -p "$backup_dir"
                    echo "    [BACKUP] $conflict_file → $backup_dir/"
                    mv "$conflict_file" "$backup_dir/"
                fi
            fi
        done <<< "$stow_output"

        # Retry stow after backing up conflicts
        if stow --restow --target="$HOME" "$pkg" 2>/dev/null; then
            echo "    [OK] Stowed $pkg (after backup)"
            stow_ok+=("$pkg")
        else
            echo "    [ERROR] Failed to stow $pkg even after backup"
            echo "           Run manually: cd $DOTFILES_DIR && stow --restow --verbose $pkg"
            stow_fail+=("$pkg")
            conflict_resolved=false
        fi
    fi
done

# ----------------------------
# Summary
# ----------------------------
echo
echo "[DONE] Config setup complete!"
echo
echo "  Dotfiles repo:  $DOTFILES_DIR"
echo "  Symlinked to:   $HOME and $HOME/.config"
echo

if [[ ${#stow_ok[@]} -gt 0 ]]; then
    echo "  Stowed successfully: ${stow_ok[*]}"
fi
if [[ ${#stow_skip[@]} -gt 0 ]]; then
    echo "  Skipped (not found): ${stow_skip[*]}"
fi
if [[ ${#stow_fail[@]} -gt 0 ]]; then
    echo "  Failed (manual fix needed): ${stow_fail[*]}"
fi

echo
echo "To manually re-stow a package, run:"
echo "  cd $DOTFILES_DIR && stow --restow <package>"
echo
echo "To unstow (remove symlinks):"
echo "  cd $DOTFILES_DIR && stow -D <package>"
