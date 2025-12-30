#!/usr/bin/env bash

# Options
shutdown="Shutdown"
reboot="Reboot"
lock="Lock"
suspend="Suspend"
logout="Logout"

# Rofi command
chosen=$(printf "%s\n" "$shutdown" "$reboot" "$lock" "$suspend" "$logout" \
    | rofi -dmenu -i -p "Power Menu")

case "$chosen" in
    "$shutdown") systemctl poweroff ;;
    "$reboot") systemctl reboot ;;
    "$lock") hyprlock ;;
    "$suspend") systemctl suspend ;;
    "$logout") hyprctl dispatch exit ;;
    *) exit 0 ;;
esac

