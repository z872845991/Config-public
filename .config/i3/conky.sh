#!/bin/zsh

killall -q conky

while pgrep -x >/dev/null;do sleep 1;done

conky -c ~/.config/i3/system-overview
