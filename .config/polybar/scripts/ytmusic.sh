#!/usr/bin/env bash

pick_player() {
    local p
    p="$(playerctl -l 2>/dev/null | grep -i -E 'youtube|ytm|ytmdesktop' | head -n1)"
    if [ -n "$p" ]; then
        echo "$p"
    else
        echo "playerctld"
    fi
}

format_line() {
    local status="$1" artist="$2" title="$3"
    local icon=""
    local max=42
    local text="${artist} - ${title}"
    if [ "${#text}" -gt "$max" ]; then
        text="${text:0:$((max - 1))}…"
    fi
    case "$status" in
    Playing) echo "%{F#ff5555}${icon}%{F-} ${text}" ;;
    Paused) echo "%{F#bd93f9}${icon}%{F-} ${text}" ;;
    *) echo "${icon}  YT Music" ;;
    esac
}

run_follow() {
    local player="$1"
    playerctl -p "$player" metadata --follow \
        --format '{{status}}|{{xesam:artist}}|{{xesam:title}}' 2>/dev/null |
        while IFS='|' read -r status artist title; do
            # 防止空值
            [ -z "$artist" ] && artist="Unknown"
            [ -z "$title" ] && title="Unknown"
            format_line "$status" "$artist" "$title"
        done
}

case "$1" in
--click-left)
    P="$(pick_player)"
    playerctl -p "$P" play-pause 2>/dev/null
    exit 0
    ;;
--click-right)
    xdg-open "https://music.youtube.com" >/dev/null 2>&1 &
    exit 0
    ;;
--scroll-up)
    P="$(pick_player)"
    playerctl -p "$P" previous 2>/dev/null
    exit 0
    ;;
--scroll-down)
    P="$(pick_player)"
    playerctl -p "$P" next 2>/dev/null
    exit 0
    ;;
esac

P="$(pick_player)"
status="$(playerctl -p "$P" status 2>/dev/null || true)"
artist="$(playerctl -p "$P" metadata xesam:artist 2>/dev/null || true)"
title="$(playerctl -p "$P" metadata xesam:title 2>/dev/null || true)"
format_line "$status" "$artist" "$title"

run_follow "$P"
