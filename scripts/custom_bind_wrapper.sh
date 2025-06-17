#!/bin/bash
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "$SCRIPT_DIR/env_runtime.sh"
source "$SCRIPT_DIR/env_prism.sh"

[ "$BINDS_ENABLED" = "1" ] || exit 0

CMDS_JSON="$1"

echo "$CMDS_JSON" | jq -r '.[]' | while IFS= read -r cmd; do
  [ -z "$cmd" ] && continue
  bash -c "$cmd" &
done
