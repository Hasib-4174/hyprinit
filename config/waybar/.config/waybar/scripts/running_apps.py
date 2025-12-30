#!/usr/bin/env python3
import json
import subprocess
import sys

# Define Icon Mapping (Add your apps here)
icon_map = {
    "firefox": "", "code": "", "terminal": "", "kitty": "",
    "discord": "", "spotify": "", "vlc": "嗢", "thunar": "",
    "obs": "", "rofi": ""
}

def get_hyprland_clients():
    try:
        output = subprocess.check_output(["hyprctl", "clients", "-j"])
        return json.loads(output)
    except: return []

# def get_sway_clients(): 
#     # Logic for swaymsg -t get_tree if needed
#     pass

def main():
    clients = get_hyprland_clients()
    unique_classes = set()
    
    # Filter for active workspace or all? displaying all unique running apps
    for client in clients:
        if client['class']:
            unique_classes.add(client['class'].lower())

    icons = []
    tooltip = []

    for app in unique_classes:
        # Default icon if not found
        icon = icon_map.get(app, "") 
        icons.append(icon)
        tooltip.append(app)

    output = {
        "text": " ".join(icons),
        "tooltip": "Running: " + ", ".join(tooltip),
        "class": "custom-running-apps"
    }
    print(json.dumps(output))

if __name__ == "__main__":
    main()
