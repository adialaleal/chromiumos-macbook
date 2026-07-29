#!/usr/bin/env bash
# ==============================================================================
# Apple SMC Thermal & Fan Speed Daemon for ChromiumOS
# Keeps older MacBooks quiet while managing CPU temperatures efficiently.
# ==============================================================================

set -euo pipefail

FAN_SYS_DIR="/sys/devices/platform/applesmc.784"
TEMP_SYS=$(find /sys/class/hwmon -name "temp1_input" 2>/dev/null | head -n 1 || true)

if [[ ! -d "$FAN_SYS_DIR" || -z "$TEMP_SYS" ]]; then
    echo "applesmc thermal nodes not available."
    exit 0
fi

# Fan speed sysfs controls
FAN_MIN=$(cat "${FAN_SYS_DIR}/fan1_min" 2>/dev/null || echo 1200)
FAN_MAX=$(cat "${FAN_SYS_DIR}/fan1_max" 2>/dev/null || echo 6200)
FAN_OUTPUT="${FAN_SYS_DIR}/fan1_output"
FAN_MANUAL="${FAN_SYS_DIR}/fan1_manual"

# Temperature thresholds in milliCelsius (55C - 85C)
TEMP_LOW=55000
TEMP_HIGH=85000

get_cpu_temp() {
    cat "$TEMP_SYS" 2>/dev/null || echo 50000
}

adjust_fan_speed() {
    local temp
    temp=$(get_cpu_temp)

    if (( temp < TEMP_LOW )); then
        # Quiet mode: Min fan speed
        echo 0 > "$FAN_MANUAL" 2>/dev/null || true
    elif (( temp > TEMP_HIGH )); then
        # Maximum cooling mode
        echo 1 > "$FAN_MANUAL" 2>/dev/null || true
        echo "$FAN_MAX" > "$FAN_OUTPUT" 2>/dev/null || true
    else
        # Dynamic linear scaling
        local ratio=$(( (temp - TEMP_LOW) * 100 / (TEMP_HIGH - TEMP_LOW) ))
        local target_rpm=$(( FAN_MIN + (FAN_MAX - FAN_MIN) * ratio / 100 ))
        echo 1 > "$FAN_MANUAL" 2>/dev/null || true
        echo "$target_rpm" > "$FAN_OUTPUT" 2>/dev/null || true
    fi
}

case "${1:-status}" in
    daemon)
        echo "Starting MacBook SMC Thermal Daemon..."
        while true; do
            adjust_fan_speed
            sleep 5
        done
        ;;
    status)
        RAW_TEMP=$(get_cpu_temp)
        CELSIUS=$((RAW_TEMP / 1000))
        echo "Temperatura Atual da CPU: ${CELSIUS}°C"
        echo "Faixa de Ventoinha SMC:  ${FAN_MIN} RPM - ${FAN_MAX} RPM"
        ;;
    *)
        echo "Uso: $0 {daemon|status}"
        exit 1
        ;;
esac
