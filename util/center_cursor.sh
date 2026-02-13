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
if [ ! -s "$CACHE" ]; then
  read CENTER_X CENTER_Y <<<"$(
  hyprctl monitors -j |
  jq -r --argjson mid "$MONITOR_ID" '
      .[] |
      select(.id == $mid) |
      [
        (.x + (.width / .scale / 2)),
        (.y + (.height / .scale / 2))
      ] |
      @sh
    '
  )"
  echo "$CENTER_X $CENTER_Y" > "$STATE_DIR/monitor_center_$MONITOR_ID"
else
  read CENTER_X CENTER_Y < "$CACHE"
fi

hyprctl -q dispatch movecursor "$CENTER_X" "$CENTER_Y"
