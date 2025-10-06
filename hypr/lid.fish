#!/usr/bin/env fish

echo (date)": Lid script executed with argument "$argv[1] >> /tmp/lid.log

if string match -r "\sHDMI-A-[0-9]+" (hyprctl monitors)
  echo (date)": HDMI monitor detected" >> /tmp/lid.log
  if test "$argv[1]" = "open"
    echo (date)": Lid opened" >> /tmp/lid.log
    hyprctl keyword monitor "eDP-1,1920x1080,1920x0,1"
  else
    echo (date)": Lid closed" >> /tmp/lid.log
    hyprctl keyword monitor "eDP-1,disable"
  end
else
  echo (date)": HDMI monitor not detected" >> /tmp/lid.log
end
