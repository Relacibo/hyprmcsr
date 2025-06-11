#!/bin/bash

SCRIPT_PATH=$(dirname $(realpath "$0"))
CONFIG_FILE="$SCRIPT_PATH/../config.json"
WINDOW_ADDRESS_FILE="$SCRIPT_PATH/../var/window_address"

PRISM_INSTANCE_ID=$(jq -r '.minecraft.prismInstanceId' "$CONFIG_FILE")
window_regex=$(jq -r '.minecraft.windowTitleRegex' "$CONFIG_FILE")

# Use wayland
prismlauncher -l "$PRISM_INSTANCE_ID" & # Start Minecraft

timeout=20
elapsed=0
window_address=""
window_pid=""

while [ $elapsed -lt $timeout ]; do
  window_info=$(hyprctl clients -j | jq -r --arg regex "$window_regex" '
    .[] | select(.title | test($regex)) | "\(.address) \(.pid)"
  ')
  window_address=$(echo "$window_info" | awk '{print $1}')
  window_pid=$(echo "$window_info" | awk '{print $2}')
  if [ -n "$window_address" ]; then
    echo "$window_address" > "$WINDOW_ADDRESS_FILE"
    break
  fi
  sleep 1
  elapsed=$((elapsed + 1))
done

if [ -z "$window_address" ]; then
  echo "Kein Minecraft-Fenster gefunden (Timeout nach $timeout Sekunden)."
  exit 1
fi

hyprctl --batch "
  dispatch setprop address:$window_address noanim 1;
  dispatch setprop address:$window_address norounding 1
"

for i in {1..20}; do
  sink_input_id=$(pactl list sink-inputs | awk '
    BEGIN { id="" }
    /node.name = "java"/ { java=1 }
    /media.role = "game"/ { game=1 }
    /Sink Input/ {
      if(java && game) { print id; exit }
      id=$3; java=0; game=0
    }
  ')
  if [ -n "$sink_input_id" ]; then
    pactl move-sink-input "$sink_input_id" virtual_game
    echo "Minecraft-Sound auf virtual_game umgeleitet."
    break
  fi
  sleep 1
done
