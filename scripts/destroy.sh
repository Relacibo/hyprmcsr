#!/bin/bash
export SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")

# Source env scripts from util
source "$SCRIPT_DIR/../util/env_core.sh"
source "$SCRIPT_DIR/../util/env_prism.sh"
source "$SCRIPT_DIR/../util/env_runtime.sh"

# Export all relevant environment variables for child processes
source "$SCRIPT_DIR/../util/export_env.sh"

toggle_binds_key=$(jq -r '.binds.toggleBinds' "$PROFILE_CONFIG_FILE")
if [ -n "$toggle_binds_key" ] && [ "$toggle_binds_key" != "null" ]; then
  hyprctl -q keyword unbind $toggle_binds_key
fi

# Remove custom binds
custom_binds=$(jq -r '.binds.custom // {} | to_entries[] | .key' "$PROFILE_CONFIG_FILE")
if [ -n "$custom_binds" ]; then
  while IFS= read -r bind; do
    hyprctl -q keyword unbind "$bind"
  done <<< "$custom_binds"
fi

jq -r '.binds.modeSwitch | to_entries[] | "\(.key) \(.value)"' "$PROFILE_CONFIG_FILE" | while read -r mode key; do
  hyprctl -q keyword unbind $key
done

# Run onDestroy commands from profile config (all in background, with all relevant environment variables)
LOG_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/hyprmcsr/logs"
mkdir -p "$LOG_DIR"
on_destroy_cmds=$(jq -c '.onDestroy[]?' "$PROFILE_CONFIG_FILE")
if [ -n "$on_destroy_cmds" ]; then
  (
    export PROFILE HYPRMCSR_PROFILE HYPRMCSR STATE_DIR PRISM_PREFIX MINECRAFT_ROOT PRISM_INSTANCE_ID WINDOW_ADDRESS
    index=0
    while IFS= read -r cmd; do
      "$SCRIPT_DIR/../util/run_conditional_command.sh" "$cmd" "$LOG_DIR/onDestroy${index}.log"
      index=$((index + 1))
    done <<< "$on_destroy_cmds"
  )
fi

# Stop observe_state process group if PID file exists
if [ -f "$STATE_DIR/observe_state.pid" ]; then
  OBSERVE_PID=$(cat "$STATE_DIR/observe_state.pid")
  if kill -0 "$OBSERVE_PID" 2>/dev/null; then
   kill -TERM -"$OBSERVE_PID"
  fi
  rm -f "$STATE_DIR/observe_state.pid"
fi


# Only remove state files, but keep prism_instance_id and minecraft_root for session persistence
find "$STATE_DIR" -mindepth 1 -maxdepth 1 ! -name 'prism_instance_id' ! -name 'minecraft_root' -exec rm -rf {} +
