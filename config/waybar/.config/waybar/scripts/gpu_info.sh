#!/bin/bash
# Tries to read AMDGPU usage from sysfs. Lighter than radeontop.
GPU_PATH="/sys/class/drm/card0/device"
USAGE=$(cat $GPU_PATH/gpu_busy_percent 2>/dev/null || echo "0")
TEMP=$(sensors | grep "edge:" | head -1 | awk '{print $2}' | tr -d '+')

if [ -z "$TEMP" ]; then TEMP="N/A"; fi

cat <<EOF
{"text": "$USAGE%", "tooltip": "Radeon Integrated\nUsage: $USAGE%\nTemp: $TEMP", "class": "custom-gpu"}
EOF
