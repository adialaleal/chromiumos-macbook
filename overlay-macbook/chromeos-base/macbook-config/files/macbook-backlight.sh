#!/usr/bin/env bash
# MacBook Keyboard Backlight Controller for ChromiumOS
# Manages /sys/class/leds/smc::kbd_backlight/brightness

BACKLIGHT_SYS="/sys/class/leds/smc::kbd_backlight/brightness"
MAX_BACKLIGHT_SYS="/sys/class/leds/smc::kbd_backlight/max_brightness"

if [[ ! -f "$BACKLIGHT_SYS" ]]; then
    echo "applesmc keyboard backlight sysfs node not found!"
    exit 0
fi

MAX_VAL=$(cat "$MAX_BACKLIGHT_SYS" 2>/dev/null || echo 255)
CUR_VAL=$(cat "$BACKLIGHT_SYS" 2>/dev/null || echo 0)
STEP=$((MAX_VAL / 10))

case "$1" in
    up)
        NEW_VAL=$((CUR_VAL + STEP))
        (( NEW_VAL > MAX_VAL )) && NEW_VAL=$MAX_VAL
        echo "$NEW_VAL" > "$BACKLIGHT_SYS"
        ;;
    down)
        NEW_VAL=$((CUR_VAL - STEP))
        (( NEW_VAL < 0 )) && NEW_VAL=0
        echo "$NEW_VAL" > "$BACKLIGHT_SYS"
        ;;
    off)
        echo 0 > "$BACKLIGHT_SYS"
        ;;
    on|max)
        echo "$MAX_VAL" > "$BACKLIGHT_SYS"
        ;;
    init)
        # Restore medium backlight level on boot
        INIT_VAL=$((MAX_VAL / 2))
        echo "$INIT_VAL" > "$BACKLIGHT_SYS"
        ;;
    *)
        echo "Usage: $0 {up|down|off|on|init}"
        exit 1
        ;;
esac
