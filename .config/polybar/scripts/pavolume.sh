#!/usr/bin/env bash

osd='no'
inc='2'
capvol='no'
maxvol='200'
autosync='yes'

curStatus="no"
active_sink=""
limit=$((100 - inc))
maxlimit=$((maxvol - inc))

# 重新获取默认 Sink 的名称（PipeWire 下推荐用名称而非索引）
reloadSink() {
    active_sink=$(pactl get-default-sink)
}

function volUp {
    getCurVol
    if [ "$capvol" = 'yes' ]
    then
        if [ "$curVol" -le 100 ] && [ "$curVol" -ge "$limit" ]
        then
            pactl set-sink-volume "$active_sink" 100%
        elif [ "$curVol" -lt "$limit" ]
        then
            pactl set-sink-volume "$active_sink" "+$inc%"
        fi
    elif [ "$curVol" -le "$maxvol" ] && [ "$curVol" -ge "$maxlimit" ]
    then
        pactl set-sink-volume "$active_sink" "$maxvol%"
    elif [ "$curVol" -lt "$maxlimit" ]
    then
        pactl set-sink-volume "$active_sink" "+$inc%"
    fi

    getCurVol
    [ "${osd}" = 'yes' ] && qdbus org.kde.kded /modules/kosd showVolume "$curVol" 0
    [ "${autosync}" = 'yes' ] && volSync
}

function volDown {
    pactl set-sink-volume "$active_sink" "-$inc%"
    getCurVol
    [ "${osd}" = 'yes' ] && qdbus org.kde.kded /modules/kosd showVolume "$curVol" 0
    [ "${autosync}" = 'yes' ] && volSync
}

# 获取当前 Sink 的所有输入流
function getSinkInputs {
    input_array=$(pactl list sink-inputs short | awk '{print $1}')
}

function volSync {
    getSinkInputs
    getCurVol
    for each in $input_array
    do
        pactl set-sink-input-volume "$each" "$curVol%"
    done
}

# 核心修复：使用 pactl 解析当前音量
function getCurVol {
    # 提取百分比数字
    curVol=$(pactl get-sink-volume "$active_sink" | grep -Po '[0-9]+(?=%)' | head -n 1)
    [ -z "$curVol" ] && curVol=0
}

function volMute {
    case "$1" in
        mute)
            pactl set-sink-mute "$active_sink" 1
            curVol=0
            status=1
            ;;
        unmute)
            pactl set-sink-mute "$active_sink" 0
            getCurVol
            status=0
            ;;
    esac
    [ "${osd}" = 'yes' ] && qdbus org.kde.kded /modules/kosd showVolume ${curVol} ${status}
}

# 核心修复：使用 pactl 获取静音状态
function volMuteStatus {
    curStatus=$(pactl get-sink-mute "$active_sink" | awk '{print $2}')
}

function listen {
    firstrun=0
    # PipeWire 同样支持 pactl subscribe
    pactl subscribe 2>/dev/null | while read -r event; do
        if echo "$event" | grep -qE "sink|server"; then
            output
        fi
    done
}

function output() {
    reloadSink
    getCurVol
    volMuteStatus
    if [ "${curStatus}" = 'yes' ]
    then
        echo " $curVol%"
    else
        echo " $curVol%"
    fi
}

reloadSink
case "$1" in
    --up) volUp ;;
    --down) volDown ;;
    --togmute)
        volMuteStatus
        if [ "$curStatus" = 'yes' ]; then volMute unmute; else volMute mute; fi
        ;;
    --mute) volMute mute ;;
    --unmute) volMute unmute ;;
    --sync) volSync ;;
    --listen) 
        output # 先打印一次当前状态
        listen 
        ;;
    *) output ;;
esac
