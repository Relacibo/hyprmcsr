#!/bin/bash
sudo bash -c :

SCRIPT_PATH=$(dirname $(realpath "$0"))
CONFIG_FILE="$SCRIPT_PATH/../config.json"
WINDOW_ADDRESS_FILE="$SCRIPT_PATH/var/window_address"

if ! command -v jq >/dev/null; then
  echo "jq wird benötigt!"
  exit 1
fi

# Binds setzen
jq -r '.binds.modeSwitch | to_entries[] | "\(.key) \(.value)"' "$CONFIG_FILE" | while read -r mode key; do
  hyprctl keyword bindni $key,exec,"$SCRIPT_PATH/hyprmcsr.sh $mode"
done

echo "Hyprmcsr-Binds aus config.json gesetzt."

if [ "$1" = "--coop" ]; then
  $SCRIPT_PATH/ninjalink.sh &
fi

PRISM_INSTANCE_NAME=$(jq -r '.minecraft.prismInstanceName' "$CONFIG")

flatpak run com.obsproject.Studio & # Start OBS
$SCRIPT_PATH/ninjabrain.sh
sleep 2s # Sleeping to avoid race condition with the sound

# Input Remapper für Mäuse
jq -c '.inputRemapper.mouses[]' "$CONFIG" | while read -r mouse; do
  device=$(echo "$mouse" | jq -r '.device')
  preset=$(echo "$mouse" | jq -r '.preset')
  sudo input-remapper-control --command start --device "$device" --preset "$preset"
done

# Input Remapper für Tastaturen
jq -c '.inputRemapper.keyboards[]' "$CONFIG" | while read -r keyboard; do
  device=$(echo "$keyboard" | jq -r '.device')
  preset=$(echo "$keyboard" | jq -r '.preset')
  input-remapper-control --command start --device "$device" --preset "$preset"
done

mkdir -p $SCRIPT_PATH/var

$SCRIPT_PATH/minecraft.sh
