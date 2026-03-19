#!/bin/zsh

killall -q conky

while pgrep -x >/dev/null;do sleep 2;done

conky -c ~/.config/i3/system-overview
