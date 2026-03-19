#!/bin/bash
text=$(rofi -dmenu -p "输入翻译内容")
trans :zh "$text" | rofi -dmenu -theme "显示翻译结果的主题"
