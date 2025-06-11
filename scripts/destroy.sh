#!/bin/bash
sudo input-remapper-control --command stop-all

DIRNAME=$(dirname $(realpath "$0"))
CONFIG_FILE="$DIRNAME/../config.json"

if ! command -v jq >/dev/null; then
  echo "jq wird benötigt!"
  exit 1
fi

jq -r '.binds.modeSwitch | to_entries[] | select(.key != "default") | .value' "$CONFIG_FILE" | while read -r key; do
  hyprctl keyword unbind $key
done

echo "Hyprmcsr-Binds entfernt."
