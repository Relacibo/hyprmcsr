#!/bin/bash
sudo input-remapper-control --command stop-all

SCRIPT_DIR=$(dirname $(realpath "$0"))
CONFIG_FILE="$SCRIPT_DIR/../config.json"
WINDOW_ADDRESS=$(cat "$SCRIPT_DIR/../var/window_address" 2>/dev/null || echo "")

toggle_binds_key=$(jq -r '.binds.toggleBinds' "$CONFIG_FILE")
if [ -n "$toggle_binds_key" ] && [ "$toggle_binds_key" != "null" ]; then
  hyprctl keyword unbind $toggle_binds_key
fi

# Custom binds entfernen
custom_binds=$(jq -r '.binds.custom | to_entries[] | .key' "$CONFIG_FILE")
if [ -n "$custom_binds" ]; then
  while IFS= read -r bind; do
    hyprctl keyword unbind "$bind"
  done <<< "$custom_binds"
fi

jq -r '.binds.modeSwitch | to_entries[] | "\(.key) \(.value)"' "$CONFIG_FILE" | while read -r mode key; do
  hyprctl keyword unbind $key
done
PROFILE=$(cat "$SCRIPT_DIR/../var/profile" 2>/dev/null || echo "default")
on_destroy_cmds=$(jq -r '.onDestroy[]?' "$CONFIG_FILE")
if [ -n "$on_destroy_cmds" ]; then
  while IFS= read -r cmd; do
    WINDOW_ADDRESS="$WINDOW_ADDRESS" SCRIPT_DIR="$SCRIPT_DIR" PROFILE="$PROFILE" bash -c "$cmd" &
  done <<< "$on_destroy_cmds"
fi

rm -rf "$SCRIPT_DIR/../var"
