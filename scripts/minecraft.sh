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

# ...existing code...

# Prüfe, ob pipewireLoopback aktiviert ist
pipewire_enabled=$(jq -r '.pipewireLoopback.enabled // 0' "$CONFIG_FILE")
if [ "$pipewire_enabled" = "1" ] || [ "$pipewire_enabled" = "true" ]; then
  for i in {1..20}; do
    sink_input_id=$(pactl -f json list sink-inputs | jq -r '
      .[] | select(
        ((.properties."application.name" == "java") or (.properties."node.name" == "java"))
        and ((.properties."media.role" // "" | ascii_downcase) == "game")
      ) | .index
    ' | head -n1)
    if [ -n "$sink_input_id" ]; then
      pactl move-sink-input "$sink_input_id" virtual_game
      echo "Minecraft-Sound auf virtual_game umgeleitet."
      break
    fi
    sleep 1
  done
fi
# ...existing code...
