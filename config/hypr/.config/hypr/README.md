# Hyprland Modular Configuration

This directory contains a fully modular, scalable, and maintainable
Hyprland configuration. The setup is designed for long-term use, easy
debugging, and fast customization without touching unrelated components.

The configuration follows Hyprland best practices and is organized by
responsibility rather than size.

------------------------------------------------------------------------

## Goals of This Setup

-   Keep `hyprland.conf` minimal and stable
-   Isolate concerns (appearance, input, keybinds, layouts, rules)
-   Allow safe future modifications without breaking the system
-   Make troubleshooting fast and predictable
-   Support long-term growth (themes, scripts, multi-monitor, IPC)

------------------------------------------------------------------------

## Directory Structure

``` text
~/.config/hypr/
│
├── hyprland.conf            # Entry point (sources all other files)
│
├── env.conf                 # Environment variables
├── monitors.conf            # Monitor layout & resolution
├── programs.conf            # Default programs & variables
├── autostart.conf           # Startup services and scripts
│
├── appearance.conf          # Gaps, borders, colors, blur, shadows
├── animations.conf          # All animations and curves
├── layouts.conf             # dwindle / master layout configs
├── input.conf               # Keyboard, mouse, touchpad
├── misc.conf                # Misc Hyprland options
│
├── keybinds.conf            # All keybindings
├── windowrules.conf         # Window & workspace rules
│
└── README.md                # Documentation (this file)
```

------------------------------------------------------------------------

## File Responsibilities

### hyprland.conf

Main entry file. Contains only `source = ...` statements.

This file should never contain logic or settings.

------------------------------------------------------------------------

### env.conf

Defines environment variables such as: - Cursor size - Hyprland-specific
environment settings

Changes here usually require a Hyprland restart.

------------------------------------------------------------------------

### monitors.conf

Defines: - Monitor names - Resolution - Refresh rate - Position and
scale

Useful for quickly switching between laptop-only and multi-monitor
setups.

------------------------------------------------------------------------

### programs.conf

Central place for user programs and variables: - Terminal - File
manager - App launcher - Main modifier key

Changing apps here updates bindings globally.

------------------------------------------------------------------------

### autostart.conf

Programs and scripts launched once per session: - Waybar - Hypridle -
Wallpaper services - Background scripts

Keeps startup behavior clean and predictable.

------------------------------------------------------------------------

### appearance.conf

All visual settings: - Gaps - Borders - Colors - Rounding - Shadows -
Blur and vibrancy

Theme-related changes should only happen here.

------------------------------------------------------------------------

### animations.conf

Controls: - Animation enable/disable - Bezier curves - Window, layer,
workspace animations

Separated so animations can be tuned or disabled without affecting
layout.

------------------------------------------------------------------------

### layouts.conf

Defines layout behavior: - Dwindle options - Master layout rules

Useful for quickly experimenting with different tiling strategies.

------------------------------------------------------------------------

### input.conf

Input devices configuration: - Keyboard layout - Mouse sensitivity -
Touchpad behavior - Per-device overrides

Hardware-specific settings belong here.

------------------------------------------------------------------------

### misc.conf

Miscellaneous Hyprland behavior: - Logo/wallpaper suppression - Default
behavior flags

Anything that does not fit elsewhere goes here.

------------------------------------------------------------------------

### keybinds.conf

All keyboard and mouse bindings: - App launchers - Window management -
Workspace control - Media and brightness keys - Scripts and utilities

Bindings should never be defined outside this file.

------------------------------------------------------------------------

### windowrules.conf

Window and workspace rules: - Floating behavior - Focus rules - XWayland
fixes - Suppressed events

Keeps application-specific logic isolated.

------------------------------------------------------------------------

## Recommended Workflow

-   UI tweaks → appearance.conf
-   New keybinds → keybinds.conf
-   Startup apps → autostart.conf
-   Hardware changes → input.conf / monitors.conf
-   App-specific behavior → windowrules.conf

------------------------------------------------------------------------

## Reloading & Restarting

Reload config (where supported):

``` bash
hyprctl reload
```

Some changes require a full Hyprland restart: - Environment variables -
Permissions - Certain input or monitor changes

------------------------------------------------------------------------

## Future Extensions

This structure supports: - Theme switching - Profile-based configs
(laptop / docked) - IPC-driven reloads - Dotfiles repository
integration - Scripting and automation

------------------------------------------------------------------------

## Notes

-   Keep files small and focused
-   Avoid duplicate settings across files
-   Comment aggressively when adding complex rules
-   Treat this directory as source code

------------------------------------------------------------------------

End of documentation.
