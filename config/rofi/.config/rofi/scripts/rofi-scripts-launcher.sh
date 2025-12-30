#!/usr/bin/env bash

# Directory containing your scripts
SCRIPT_DIR="$HOME/scripts"

# Check if an input argument is provided (i.e., a script was selected)
if [[ -n "$1" ]]; then
    # Execute the selected script
    # The script path is passed as $1 from rofi
    exec "$1"
else
    # This block is for Rofi to build the menu list

    # Find all executable files in the SCRIPT_DIR
    # -L: Follow symbolic links
    # -executable: Find executable files
    # -print0: Use null terminator for safer piping
    find -L "$SCRIPT_DIR" -maxdepth 1 -executable -type f -print0 | 
    while IFS= read -r -d $'\0' SCRIPT_PATH; do
        # Extract the base filename (e.g., "screenshot.sh")
        SCRIPT_NAME=$(basename "$SCRIPT_PATH")
        
        # Output the script name and the full path (used for execution)
        # Format: Display Name \0 Icon \0 Action Path
        echo -en "$SCRIPT_NAME\x00icon\x00$SCRIPT_PATH\n"
    done
fi