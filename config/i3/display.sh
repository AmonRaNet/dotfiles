#!/bin/sh
#xrandr --output VIRTUAL1 --off --output eDP1 --off --output DP1 --primary --mode 3840x2160 --pos 0x0 --rotate normal --output HDMI2 --off --output HDMI1 --off --output DP2 --off
#xrandr --dpi 200
i3-msg reload
i3-msg restart
