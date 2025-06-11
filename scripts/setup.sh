#!/bin/bash
sudo bash -c :

DIRNAME=$(dirname $(realpath "$0"))

if ! command -v jq >/dev/null; then
  echo "jq wird benötigt!"
  exit 1
fi

jq -r '.binds.modes | to_entries[] | "\(.key) \(.value)"' "$DIRNAME/../config.json" | while read -r mode key; do
  hyprctl keyword bindni $key,exec,"$DIRNAME/hyprmcsr.sh $mode"
done

echo "Hyprmcsr-Binds aus config.json gesetzt."

PRISM_INSTANCE_NAME="1.16.1" # Replace with the (real) name of your instance

if [ "$1" = "--coop" ]; then
  $DIRNAME/ninjalink.sh &
fi

# Here I let prism use my virtual audio cable
CURRENT_DEFAULT_SINK=$(pactl get-default-sink)
pactl set-default-sink virtual_game 
flatpak run com.obsproject.Studio & # Start OBS
$DIRNAME/ninjabrain.sh
sleep 2s # Sleeping to avoid race condition with the sound
prismlauncher -l "$PRISM_INSTANCE_NAME" & # Start minecraft

# Shortcuts
sudo input-remapper-control --command start --device "Razer Razer Viper V3 Pro" --preset MCSR || sudo input-remapper-control --command start --device "Razer Viper V3 Pro" --preset MCSR
input-remapper-control --command start --device "Ducky Ducky One 3 TKL " --preset MCSR

sleep 20s # Sleeping to avoid race condition with the sound
pactl set-default-sink $CURRENT_DEFAULT_SINK # Reset back to old default sink
