#!/bin/sh

MODE_FILE=".config/i3/display_mode"

# if we don't have a file, start at zero
if [ ! -f $MODE_FILE ] ; then
  monitor_mode="BOTH"
else
  monitor_mode=`cat $MODE_FILE`
fi

if [ $monitor_mode = "BOTH" ]; then
        monitor_mode="CLONES"
elif [ $monitor_mode = "CLONES" ]; then
        monitor_mode="INTERNAL"
elif [ $monitor_mode = "INTERNAL" ]; then
        monitor_mode="EXTERNAL"
elif [ $monitor_mode = "EXTERNAL" ]; then
        monitor_mode="BOTH"
fi

echo "${monitor_mode}" > $MODE_FILE

# Apply change
sh .config/i3/display.sh
