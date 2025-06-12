#!/bin/bash
sudo input-remapper-control --command stop-all

SCRIPT_PATH=$(dirname $(realpath "$0"))
CONFIG_FILE="$SCRIPT_PATH/../config.json"

toggle_binds_key=$(jq -r '.binds.toggleBinds' "$CONFIG_FILE")
if [ -n "$toggle_binds_key" ] && [ "$toggle_binds_key" != "null" ]; then
  hyprctl keyword unbind $toggle_binds_key
fi

$SCRIPT_PATH/toggle_binds.sh 0

rm -rf "$SCRIPT_PATH/../var"
