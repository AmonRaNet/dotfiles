#!/bin/sh
xrandr --output DVI-D-0 --off --output HDMI-0 --primary --mode 3840x2160 --pos 0x0 --rotate normal
xrandr --dpi 96
gsettings set org.gnome.desktop.interface text-scaling-factor 1.0
