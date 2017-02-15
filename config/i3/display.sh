#!/bin/sh

# Files
INTERNAL_FILE=".config/i3/display_internal"
EXTERNAL_FILE=".config/i3/display_external"
MODE_FILE=".config/i3/display_mode"

# Custom for each machine (please define in related files your output names, like DVI-0)
INTERNAL_OUTPUT=`cat $INTERNAL_FILE`
EXTERNAL_OUTPUT=`cat $EXTERNAL_FILE`

# if we don't have a file, start at zero
if [ ! -f $MODE_FILE ] ; then
  monitor_mode="BOTH"
else
  monitor_mode=`cat $MODE_FILE`
fi

if [ $monitor_mode = "BOTH" ]; then
  xrandr --output $INTERNAL_OUTPUT --auto --output $EXTERNAL_OUTPUT --auto --left-of $INTERNAL_OUTPUT
elif [ $monitor_mode = "CLONES" ]; then
  xrandr --output $INTERNAL_OUTPUT --auto --output $EXTERNAL_OUTPUT --auto --same-as $INTERNAL_OUTPUT
elif [ $monitor_mode = "INTERNAL" ]; then
  xrandr --output $INTERNAL_OUTPUT --auto --output $EXTERNAL_OUTPUT --off
elif [ $monitor_mode = "EXTERNAL" ]; then
   xrandr --output $INTERNAL_OUTPUT --off --output $EXTERNAL_OUTPUT --auto
fi

# Calculate and aplly DPI
MONITOR_0_RES=`xrandr --listmonitors | grep 0: | awk '{print $3}' | awk -F '/' '{print $1}'`
if [ "$MONITOR_0_RES" -gt "1680" ]; then
   MONITOR_DPI="148"
else
   MONITOR_DPI="96"
fi
xrandr --dpi $MONITOR_DPI

# Reload i3
i3-msg reload
i3-msg restart

# Show tooltip
MONITORS=`xrandr --listmonitors`
notify-send Display-mode "$MONITORS \n DPI: $MONITOR_DPI \n Mode: $monitor_mode"
