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

# Run onDestroy commands from profile config and wait for them before cleanup
LOG_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/hyprmcsr/logs"
mkdir -p "$LOG_DIR"
on_destroy_cmds=$(jq -c '.onDestroy[]?' "$PROFILE_CONFIG_FILE")
if [ -n "$on_destroy_cmds" ]; then
  (
    export PROFILE HYPRMCSR_PROFILE HYPRMCSR STATE_DIR PRISM_PREFIX MINECRAFT_ROOT PRISM_INSTANCE_ID WINDOW_ADDRESS
    export HYPRMCSR_RUN_CONDITIONAL_IN_BACKGROUND=0
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


# Remove transient state files but preserve persistent instance data
# (window_address, prism_instance_id, minecraft_root) so hyprmcsr can
# reconnect to a still-running Minecraft window on next start.
if [ -n "$STATE_DIR" ]; then
  find "$STATE_DIR" -maxdepth 1 -type f \
    ! -name "window_address" \
    ! -name "prism_instance_id" \
    ! -name "minecraft_root" \
    -delete
fi
