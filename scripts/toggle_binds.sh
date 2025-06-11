#!/bin/bash
# filepath: /home/reinhard/git/hyprmcsr/scripts/toggle_binds.sh

SCRIPT_PATH=$(dirname "$(realpath "$0")")
CONFIG_FILE="$SCRIPT_PATH/../config.json"
STATE_FILE="$SCRIPT_PATH/../var/binds_enabled"

if ! command -v jq >/dev/null; then
  echo "jq is required!"
  exit 1
fi

activate_binds() {
  jq -r '.binds.modeSwitch | to_entries[] | "\(.key) \(.value)"' "$CONFIG_FILE" | while read -r mode key; do
    hyprctl keyword bindni $key,exec,"$SCRIPT_PATH/toggle_mode.sh $mode"
  done
  echo 1 > "$STATE_FILE"
  echo "Hyprland binds activated."
}

deactivate_binds() {
  jq -r '.binds.modeSwitch | to_entries[] | "\(.key) \(.value)"' "$CONFIG_FILE" | while read -r mode key; do
    hyprctl keyword unbind $key
  done
  echo 0 > "$STATE_FILE"
  echo "Hyprland binds deactivated."
}

# Argument handling
if [ $# -eq 0 ]; then
  # Toggle
  if [ -f "$STATE_FILE" ] && [ "$(cat "$STATE_FILE")" = "1" ]; then
    deactivate_binds
  else
    activate_binds
  fi
elif [ "$1" = "1" ]; then
  if [ ! -f "$STATE_FILE" ] || [ "$(cat "$STATE_FILE")" != "1" ]; then
    activate_binds
  else
    echo "Binds already active."
  fi
elif [ "$1" = "0" ]; then
  if [ -f "$STATE_FILE" ] && [ "$(cat "$STATE_FILE")" = "1" ]; then
    deactivate_binds
  else
    echo "Binds already inactive."
  fi
else
  echo "Usage: $0 [1|0]"
  exit 1
fi
