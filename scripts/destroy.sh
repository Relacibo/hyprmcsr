#!/bin/bash
export SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")

# Source env scripts from util
source "$SCRIPT_DIR/../util/env_core.sh"
source "$SCRIPT_DIR/../util/env_prism.sh"
source "$SCRIPT_DIR/../util/env_runtime.sh"

# Export all relevant environment variables for child processes
SCRIPT_DIR="${SCRIPT_DIR:-$(dirname "$0")}"
source "$SCRIPT_DIR/../util/export_env.sh"

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
    export PROFILE HYPRMCSR_PROFILE HYPRMCSR STATE_DIR PRISM_PREFIX MINECRAFT_ROOT PRISM_INSTANCE_ID WINDOW_ADDRESS
    while IFS= read -r cmd; do
      "$SCRIPT_DIR/../util/run_conditional_command.sh" "$cmd"
    done <<< "$on_destroy_cmds"
  )
fi

# Only remove state files, but keep prism_instance_id and minecraft_root for session persistence
find "$STATE_DIR" -mindepth 1 -maxdepth 1 ! -name 'prism_instance_id' ! -name 'minecraft_root' -exec rm -rf {} +
