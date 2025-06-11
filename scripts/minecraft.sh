#!/bin/bash

SCRIPT_PATH=$(dirname $(realpath "$0"))
CONFIG_FILE="$SCRIPT_PATH/../config.json"
WINDOW_ADDRESS_FILE="$SCRIPT_PATH/var/window_address"

PRISM_INSTANCE_ID=$(jq -r '.minecraft.prismInstanceId' "$CONFIG_FILE")
window_regex=$(jq -r '.minecraft.windowTitleRegex' "$CONFIG_FILE")

mkdir -p "$SCRIPT_PATH/var"
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

# Warte kurz, bis der Audio-Stream da ist
sleep 2

# Versuche, den passenden PulseAudio-Stream anhand der PID zu finden und umzuleiten
sink_input_id=$(pactl list sink-inputs | awk -v pid="$window_pid" '
  $0 ~ "application.process.id = \""pid"\"" {found=1}
  /Sink Input/ {if(found){print id; exit} id=$3}
')

if [ -n "$sink_input_id" ]; then
  pactl move-sink-input "$sink_input_id" virtual_game
  echo "Minecraft-Sound auf virtual_game umgeleitet."
else
  echo "Kein Minecraft-Sink-Input gefunden."
fi
