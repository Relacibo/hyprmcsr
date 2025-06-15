#!/bin/bash
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "$SCRIPT_DIR/env_prism.sh"
source "$SCRIPT_DIR/env_runtime.sh"

toggle_binds_key=$(jq -r '.binds.toggleBinds' "$CONFIG_FILE")
if [ -n "$toggle_binds_key" ] && [ "$toggle_binds_key" != "null" ]; then
  hyprctl keyword unbind $toggle_binds_key
fi

# Remove custom binds
custom_binds=$(jq -r '.binds.custom // {} | to_entries[] | .key' "$CONFIG_FILE")
if [ -n "$custom_binds" ]; then
  while IFS= read -r bind; do
    hyprctl keyword unbind "$bind"
  done <<< "$custom_binds"
fi

jq -r '.binds.modeSwitch | to_entries[] | "\(.key) \(.value)"' "$CONFIG_FILE" | while read -r mode key; do
  hyprctl keyword unbind $key
done

on_destroy_cmds=$(jq -r '.onDestroy[]?' "$CONFIG_FILE")
if [ -n "$on_destroy_cmds" ]; then
  (
    export WINDOW_ADDRESS SCRIPT_DIR PROFILE HYPRMCSR_PROFILE PRISM_INSTANCE_ID MINECRAFT_ROOT
    while IFS= read -r cmd; do
      bash -c "$cmd" &
    done <<< "$on_destroy_cmds"
  )
fi

rm -rf "$STATE_DIR"
