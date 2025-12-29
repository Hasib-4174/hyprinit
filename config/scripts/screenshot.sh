#!/bin/bash

# Configuration
SAVE_DIR="$HOME/Pictures/Screenshots"
TIMESTAMP=$(date +'%Y-%m-%d_%H-%M-%S')
FILE="$SAVE_DIR/screenshot_$TIMESTAMP.png"

# Ensure the save directory exists
mkdir -p "$SAVE_DIR"

# Check if swappy and slurp are installed (optional but recommended for a clean script)
if ! command -v swappy &> /dev/null || ! command -v slurp &> /dev/null; then
    echo "Error: 'swappy' and/or 'slurp' are not installed or not in PATH." >&2
    echo "This script requires grim, slurp, swappy, and wl-clipboard." >&2
    exit 1
fi

# 1. Use slurp to select a region (This prints the geometry string)
# The -w 0 argument for slurp ensures a solid background during selection
GEOMETRY=$(slurp -w 0)

# Check if the user aborted the selection (slurp returns non-zero status or empty output)
if [ -z "$GEOMETRY" ]; then
    echo "Screenshot selection aborted."
    exit 0
fi

# 2. Capture the region using grim and pipe the PNG data to swappy
# NOTE: The '2>/dev/null' redirects all error/warning text output from grim
#       (or any command before the pipe) away, ensuring ONLY the image data
#       is sent to swappy.
grim -g "$GEOMETRY" -t png - 2>/dev/null | swappy -f -

# - Pressing Ctrl+S will save it to the default path (which can be configured in ~/.config/swappy/config).
# - Pressing Ctrl+C will copy the final image to the clipboard (using wl-copy).

# Alternative: Force save to a specific file and copy to clipboard immediately after editing
# grim -g "$GEOMETRY" -t png - - | swappy -f - -o "$FILE"
# wl-copy -t image/png < "$FILE"

