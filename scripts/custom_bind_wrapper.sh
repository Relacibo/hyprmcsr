#!/bin/bash
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "$SCRIPT_DIR/../util/env_runtime.sh"
source "$SCRIPT_DIR/../util/env_prism.sh"

[ "$BINDS_ENABLED" = "1" ] || exit 0

CMDS_JSON="$1"

# Directly call the util script for each command, no helper needed

echo "$CMDS_JSON" | jq -c '.[]' | while IFS= read -r cmd; do
  [ -z "$cmd" ] && continue
  "$SCRIPT_DIR/../util/run_conditional_command.sh" "$cmd"
done
