#!/bin/bash
# filepath: /home/reinhard/git/hyprmcsr/scripts/toggle_binds.sh

source "$(dirname "$(realpath "$0")")/env_runtime.sh"

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

# Run onToggleBinds (with all relevant environment variables incl. BINDS_ENABLED)
on_toggle_cmds=$(jq -r '.onToggleBinds[]?' "$PROFILE_CONFIG_FILE")
if [ -n "$on_toggle_cmds" ]; then
  export SCRIPT_DIR HYPRMCSR_PROFILE PRISM_INSTANCE_ID MINECRAFT_ROOT WINDOW_ADDRESS BINDS_ENABLED
  while IFS= read -r cmd; do
    bash -c "$cmd" &
  done <<< "$on_toggle_cmds"
fi
