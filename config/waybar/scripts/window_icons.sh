#!/bin/bash

# Map app names to icons (edit this as you add more apps)
# Icons:  󰈹 
declare -A icons=(
  ["brave-browser"]="󰈹"
  ["firefox-developer-edition"]=""
  ["firefox"]=""
  ["google-chrome"]=""
  ["Alacritty"]=""
  ["foot"]=""
  ["kitty"]=""
  ["Code"]="󰨞"
  ["GitKraken"]=""
  ["org.kde.dolphin"]=""
  ["pcmanfm"]=" "
  ["vlc"]=""
  ["mpv"]=""
  ["imv"]=""
  ["discord"]=""
  ["steam"]=""
  ["spotify"]=""
  ["jetbrains-studio"]=""
  ["Antigravity"]="󰠄"
  ["libreoffice-writer"]=""
)

# Get all visible windows in the current workspace
#hyprctl clients -j | jq -r '.[] | .class'
hyprctl clients -j | jq -r '.[] | select(.workspace.id != -1 and .workspace.id == .workspace.id) | .class' |
  awk '!seen[$0]++' |
  while read -r app; do
    icon="${icons[$app]}"
    if [ -n "$icon" ]; then
      echo -n "$icon  "
    else
      echo -n "  " # fallback icon
    fi
  done

echo
