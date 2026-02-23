#!/bin/sh
xrandr --output DP-1 --primary --mode 5120x2160 --pos 0x0 --rotate normal --output HDMI-1 --off
xrandr --dpi 170
xrandr -r 120
gsettings set org.gnome.desktop.interface text-scaling-factor 1.4
