#!/bin/bash

num_connected_monitors=$(xrandr -q | grep -w 'connected' | wc -l)

if [ $num_connected_monitors -gt 1 ]; then
    xrandr --output DP-1 --mode 2560x1440 --primary --dpi 125 --left-of HDMI-1
    # xrandr --output eDP --off
else
    xrandr --output DP-1 --mode 2560x1440 --dpi 125
fi

