#!/bin/zsh

killall -q blueberry

while pgrep -x >/dev/null;do sleep 1;done

blueberry
