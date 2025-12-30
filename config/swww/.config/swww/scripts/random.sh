#!/bin/bash

# Define the directory for your wallpapers
WALLPAPER_DIR="$HOME/Pictures/wallpapers"

# -----------------------------------------------------
# This script only calls `swww img`
# The daemon is already running, thanks to init.sh
# -----------------------------------------------------

# Find a random wallpaper
RANDOM_WALLPAPER=$(find "$WALLPAPER_DIR" -type f | shuf -n 1)

# --- THIS IS THE MODULAR PART ---
# You can have different scripts with different transitions.
# For example, this script uses a "grow" transition.
swww img "$RANDOM_WALLPAPER" \
    --transition-type="grow" \
    --transition-pos="center" \
    --transition-duration=0.7 \
    --transition-fps=60
