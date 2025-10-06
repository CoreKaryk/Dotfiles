#!/bin/bash

STATE_FILE="/tmp/gamemode.lock"

if [ -f "$STATE_FILE" ]; then
    # Game mode is ON, turn it OFF
    hyprctl keyword animations:enabled true
    hyprctl keyword decoration:blur:enabled true
    hyprctl keyword decoration:active_opacity 0.85
    hyprctl keyword decoration:inactive_opacity 0.70
    hyprctl keyword decoration:rounding 10
    hyprctl keyword general:gaps_in 3
    hyprctl keyword general:gaps_out 6
    rm "$STATE_FILE"
else
    # Game mode is OFF, turn it ON
    hyprctl keyword animations:enabled false
    hyprctl keyword decoration:blur:enabled false
    hyprctl keyword decoration:active_opacity 1.0
    hyprctl keyword decoration:inactive_opacity 1.0
    hyprctl keyword decoration:rounding 0
    hyprctl keyword general:gaps_in 0
    hyprctl keyword general:gaps_out 0
    touch "$STATE_FILE"
fi

# Refresh Waybar to update the icon
pkill -SIGRTMIN+1 waybar
