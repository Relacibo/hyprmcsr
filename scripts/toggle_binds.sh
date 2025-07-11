#!/bin/bash
# filepath: /home/reinhard/git/hyprmcsr/scripts/toggle_binds.sh

# Source env scripts from util
export SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")
UTIL_DIR="$SCRIPT_DIR/../util"
source "$UTIL_DIR/env_core.sh"
source "$UTIL_DIR/env_prism.sh"
source "$UTIL_DIR/env_runtime.sh"

if [ $# -ge 1 ]; then
  # Set argument as value (only 0 or 1 allowed)
  if [ "$1" = "0" ] || [ "$1" = "1" ]; then
    BINDS_ENABLED="$1"
  else
    echo "Invalid argument: $1 (only 0 or 1 allowed)"
    exit 1
  fi
else
  # Toggle mode
  if [ "$BINDS_ENABLED" = "1" ]; then
    BINDS_ENABLED=0
  else
    BINDS_ENABLED=1
  fi
fi


echo "$BINDS_ENABLED" > "$STATE_DIR/binds_enabled"

# Export all relevant environment variables for child processes
SCRIPT_DIR="${SCRIPT_DIR:-$(dirname "$0")}"
source "$SCRIPT_DIR/../util/export_env.sh"

# Run onToggleBinds (with all relevant environment variables incl. BINDS_ENABLED)
on_toggle_cmds=$(jq -c '.onToggleBinds[]?' "$PROFILE_CONFIG_FILE")
if [ -n "$on_toggle_cmds" ]; then
  while IFS= read -r cmd; do
    "$SCRIPT_DIR/../util/run_conditional_command.sh" "$cmd"
  done <<< "$on_toggle_cmds"
fi
