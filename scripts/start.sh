#!/bin/bash
sudo bash -c :

SCRIPT_PATH=$(dirname $(realpath "$0"))
CONFIG_FILE="$SCRIPT_PATH/../config.json"
WINDOW_ADDRESS_FILE="$SCRIPT_PATH/../var/window_address"

if ! command -v jq >/dev/null; then
  echo "jq wird benötigt!"
  exit 1
fi

echo "default" > "$SCRIPT_PATH/../var/window_switcher_state"

$SCRIPT_PATH/toggle_binds.sh 1

toggle_binds_key=$(jq -r '.binds.toggleBinds' "$CONFIG_FILE")
if [ -n "$toggle_binds_key" ] && [ "$toggle_binds_key" != "null" ]; then
  hyprctl keyword bind $toggle_binds_key,exec,"$SCRIPT_PATH/toggle_binds.sh"
fi

if [ "$1" = "--coop" ]; then
  $SCRIPT_PATH/ninjalink.sh &
fi

PRISM_INSTANCE_NAME=$(jq -r '.minecraft.prismInstanceName' "$CONFIG")

flatpak run com.obsproject.Studio & # Start OBS
$SCRIPT_PATH/ninjabrain.sh

# Input Remapper für Devices (vereinheitlicht)
jq -c '.inputRemapper.devices[]' "$CONFIG_FILE" | while read -r device_entry; do
  device=$(echo "$device_entry" | jq -r '.device')
  preset=$(echo "$device_entry" | jq -r '.preset')
  sudo input-remapper-control --command start --device "$device" --preset "$preset"
done

mkdir -p $SCRIPT_PATH/../var

$SCRIPT_PATH/minecraft.sh

# ...existing code...

# Option aus config lesen (default: true)
auto_destroy=$(jq -r '.autoDestroyOnExit // true' "$CONFIG_FILE")

if [ "$auto_destroy" = "true" ]; then
  # Trap für SIGINT und SIGTERM setzen
  trap "$SCRIPT_PATH/destroy.sh; exit" SIGINT SIGTERM
  echo "Drücke Strg+C zum Beenden. Beim Beenden wird destroy.sh automatisch ausgeführt."
  sleep infinity
fi
