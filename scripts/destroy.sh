#!/bin/bash
SCRIPT_DIR="$(dirname "$(realpath "$0")")"

# Source env scripts from util
source "$SCRIPT_DIR/../util/env_core.sh"
source "$SCRIPT_DIR/../util/env_prism.sh"

toggle_binds_key=$(jq -r '.binds.toggleBinds' "$PROFILE_CONFIG_FILE")
if [ -n "$toggle_binds_key" ] && [ "$toggle_binds_key" != "null" ]; then
  hyprctl keyword unbind $toggle_binds_key
fi

# Remove custom binds
custom_binds=$(jq -r '.binds.custom // {} | to_entries[] | .key' "$PROFILE_CONFIG_FILE")
if [ -n "$custom_binds" ]; then
  while IFS= read -r bind; do
    hyprctl keyword unbind "$bind"
  done <<< "$custom_binds"
fi

jq -r '.binds.modeSwitch | to_entries[] | "\(.key) \(.value)"' "$PROFILE_CONFIG_FILE" | while read -r mode key; do
  hyprctl keyword unbind $key
done

# Run onDestroy commands from config.json (all in background, with all relevant environment variables)
on_destroy_cmds=$(jq -c '.onDestroy[]?' "$PROFILE_CONFIG_FILE")
if [ -n "$on_destroy_cmds" ]; then
  (
    export SCRIPT_DIR PROFILE HYPRMCSR_PROFILE
    while IFS= read -r cmd; do
      "$SCRIPT_DIR/../util/run_conditional_command.sh" "$cmd"
    done <<< "$on_destroy_cmds"
  )
fi

# Only remove state files, but keep prism_instance_id and minecraft_root for session persistence
find "$STATE_DIR" -mindepth 1 -maxdepth 1 ! -name 'prism_instance_id' ! -name 'minecraft_root' -exec rm -rf {} +
