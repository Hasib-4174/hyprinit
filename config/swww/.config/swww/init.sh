#!/bin/bash

# Define the directory for your wallpapers
WALLPAPER_DIR="$HOME/Pictures/wallpapers"

# -----------------------------------------------------
# Check if swww-daemon is already running
# -----------------------------------------------------
if ! pgrep -x swww-daemon > /dev/null
then
    echo "Starting swww-daemon..."
    # Start the daemon in the background
    swww-daemon &
    
    # Give it a second to initialize
    sleep 1
fi

# -----------------------------------------------------
# Set the initial wallpaper (same as before)
# -----------------------------------------------------
# Find a random wallpaper from your directory
RANDOM_WALLPAPER=$(find "$WALLPAPER_DIR" -type f | shuf -n 1)

# Set the wallpaper
swww img "$RANDOM_WALLPAPER" \
    --transition-type="wipe" \
    --transition-duration=1 \
    --transition-fps=60 \
    --transition-step=90
