#!/bin/bash
export SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "$SCRIPT_DIR/env_prism.sh"
source "$SCRIPT_DIR/env_runtime.sh"

# Export all relevant environment variables for child processes
export HYPRMCSR_PROFILE
export PROFILE
export HYPRMCSR_BIN
export STATE_DIR
export SCRIPT_DIR
export PRISM_PREFIX
export MINECRAFT_ROOT
export PRISM_INSTANCE_ID
export WINDOW_ADDRESS

[ "$BINDS_ENABLED" = "1" ] || exit 0

CMDS_JSON="$1"

echo "$CMDS_JSON" | jq -r '.[]' | while IFS= read -r cmd; do
  [ -z "$cmd" ] && continue
  bash -c "$cmd" &
done
