#!/bin/bash

if hyprctl monitors | grep -q 'HDMI-A-1'; then
  if [[ "$1" == "close" ]]; then
    hyprctl keyword monitor "eDP-1, disable"
  elif [[ "$1" == "open" ]]; then
    hyprctl keyword monitor "eDP-1, 1920x1080,1920x0,1"
  fi
fi
