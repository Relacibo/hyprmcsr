#!/bin/bash
UTIL_DIR=$(dirname "${BASH_SOURCE[0]}")
export SCRIPT_DIR=$(realname "$UTIL_DIR/../scripts")
source "$UTIL_DIR/env_prism.sh"
source "$UTIL_DIR/env_runtime.sh"
source "$UTIL_DIR/export_env.sh"

[ "$BINDS_ENABLED" = "1" ] || exit 0

CMDS_JSON="$1"

echo "$CMDS_JSON" | jq -r '.[]' | while IFS= read -r cmd; do
  [ -z "$cmd" ] && continue
  bash -c "$cmd" &
done
