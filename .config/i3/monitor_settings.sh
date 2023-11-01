#!/bin/bash

# 获取已连接显示器的数量
num_connected_monitors=$(xrandr -q | grep -w 'connected' | wc -l)

if [ $num_connected_monitors -gt 1 ]; then
    # 设置DPI为96
    echo 'Xft.dpi: 96' > ~/.Xresources
    xrdb -merge ~/.Xresources

    # 设置外接显示器
    xrandr --output DisplayPort-0 --mode 2560x1080 --primary --dpi 96
    # 关闭笔记本显示器
    xrandr --output eDP --off
else
    # 设置DPI为192
    echo 'Xft.dpi: 192' > ~/.Xresources
    xrdb -merge ~/.Xresources

    # 启用笔记本显示器
    xrandr --output eDP --mode 2560x1600 --dpi 192
fi

