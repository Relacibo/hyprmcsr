#!/bin/bash

export XDG_RUNTIME_DIR="/run/user/$(id -u)"

CONFIG_FILE="$(dirname $(realpath "$0"))/../config.json"

MODE="$1"

if ! command -v jq >/dev/null; then
  echo "jq wird benötigt!"
  exit 1
fi

if [ -z "$MODE" ]; then
  echo "Usage: $0 [tall|boat-eye|planar-abuse]"
  exit 1
fi

# Default-Werte laden
DEFAULT_SIZE=$(jq -r '.default.size' "$CONFIG_FILE")
DEFAULT_SENSITIVITY=$(jq -r '.default.sensitivity' "$CONFIG_FILE")

# Modus-Werte laden (können null sein)
TARGET_SIZE=$(jq -r --arg m "$MODE" '.modes[$m].size // empty' "$CONFIG_FILE")
TARGET_SENSITIVITY=$(jq -r --arg m "$MODE" '.modes[$m].sensitivity // empty' "$CONFIG_FILE")

# Fallback auf Default, falls leer
[ -z "$TARGET_SIZE" ] && TARGET_SIZE="$DEFAULT_SIZE"
[ -z "$TARGET_SENSITIVITY" ] && TARGET_SENSITIVITY="$DEFAULT_SENSITIVITY"

if [ "$TARGET_SIZE" == "null" ] || [ "$TARGET_SENSITIVITY" == "null" ]; then
  echo "Unbekannter Modus: $MODE"
  exit 1
fi

# Größe aus wxh in w und h splitten
IFS="x" read -r TARGET_WIDTH TARGET_HEIGHT <<< "$TARGET_SIZE"
IFS="x" read -r DEFAULT_WIDTH DEFAULT_HEIGHT <<< "$DEFAULT_SIZE"

client_info=$(hyprctl clients -j | jq -r '
  .[] |
  select(.title | test("^Minecraft")) |
  "\(.address) \(.size[0])x\(.size[1]) \(.workspace.id)"
')

if [ -z "$client_info" ]; then
  echo "Kein Minecraft-Fenster gefunden."
  exit 1
fi

window_address=$(echo "$client_info" | awk '{print $1}')
window_size=$(echo "$client_info" | awk '{print $2}')
workspace_id=$(echo "$client_info" | awk '{print $3}')

if [ "$window_size" == "$TARGET_SIZE" ]; then
  hyprctl --batch "
    dispatch workspace $workspace_id;
    dispatch focuswindow address:$window_address;
    dispatch setfloating;
    dispatch resizewindowpixel exact $DEFAULT_WIDTH $DEFAULT_HEIGHT,address:$window_address;
    dispatch centerwindow address:$window_address;
    keyword input:sensitivity $DEFAULT_SENSITIVITY
  "
else
  hyprctl --batch "
    dispatch workspace $workspace_id;
    dispatch focuswindow address:$window_address;
    dispatch setfloating;
    dispatch resizewindowpixel exact $TARGET_WIDTH $TARGET_HEIGHT,address:$window_address;
    dispatch centerwindow address:$window_address;
    keyword input:sensitivity $TARGET_SENSITIVITY
  "
fi
