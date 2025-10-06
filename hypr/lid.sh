#!/usr/bin/env zsh

echo "$(date): Lid script executed with argument $1" >> /tmp/lid.log

if [[ "$(hyprctl monitors)" =~ "\sHDMI-A-[0-9]+" ]]; then
  echo "$(date): HDMI monitor detected" >> /tmp/lid.log
  if [[ $1 == "open" ]]; then
    echo "$(date): Lid opened" >> /tmp/lid.log
    hyprctl keyword monitor "eDP-1,1920x1080,1920x0,1"
  else
    echo "$(date): Lid closed" >> /tmp/lid.log
    hyprctl keyword monitor "eDP-1,disable"
  fi
else
    echo "$(date): HDMI monitor not detected" >> /tmp/lid.log
fi
