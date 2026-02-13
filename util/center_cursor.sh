#!/bin/bash
# Cursor centering for Minecraft window

export SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")
source "$SCRIPT_DIR/../util/env_runtime.sh"

LAST_MONITOR_FILE="$STATE_DIR/last_monitor"

# Try cached monitor first
if [ -f "$LAST_MONITOR_FILE" ]; then
  MONITOR_ID=$(cat "$LAST_MONITOR_FILE")
else
  MONITOR_ID=$(hyprctl clients -j | jq -r ".[] | select(.address==\"$WINDOW_ADDRESS\") | .monitor")
  [ -n "$MONITOR_ID" ] && echo "$MONITOR_ID" > "$LAST_MONITOR_FILE"
fi

CACHE="$STATE_DIR/monitor_center_$MONITOR_ID"
[ ! -f "$CACHE" ] && exit 0

read CENTER_X CENTER_Y < "$CACHE"
hyprctl -q dispatch movecursor "$CENTER_X" "$CENTER_Y"
