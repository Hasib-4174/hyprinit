#!/bin/bash

# Set screenshot save directory
DIR="$HOME/Pictures/Screenshots"
mkdir -p "$DIR"

# Create timestamped filename
FILE="$DIR/screenshot_$(date +'%Y-%m-%d_%H-%M-%S').png"

# Capture full screen
grim "$FILE"

imv "$FILE"
