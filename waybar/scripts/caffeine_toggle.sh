#!/bin/bash

CAFFEINE_FILE="/tmp/caffeine_active"

toggle_caffeine() {
    if [ -f "$CAFFEINE_FILE" ]; then
        # Caffeine is active, deactivate it
        rm "$CAFFEINE_FILE"
        echo "Caffeine deactivated. Starting hypridle..."
        # Start hypridle if it's not running
        pgrep hypridle || hypridle &
    else
        # Caffeine is inactive, activate it
        touch "$CAFFEINE_FILE"
        echo "Caffeine activated. Stopping hypridle..."
        # Kill hypridle if it's running
        pkill hypridle
    fi
    # Notify Waybar to update its module
    pkill -SIGRTMIN+8 waybar
}

get_status() {
    if [ -f "$CAFFEINE_FILE" ]; then
        echo "{\"text\":\"󰅶\", \"tooltip\":\"Caffeine: ON\", \"class\":\"on\"}"
    else
        echo "{\"text\":\"󰛊\", \"tooltip\":\"Caffeine: OFF\", \"class\":\"off\"}"
    fi
}

case "$1" in
    toggle)
        toggle_caffeine
        ;;
    status)
        get_status
        ;;
    *)
        echo "Usage: $0 {toggle|status}"
        exit 1
        ;;
esac
