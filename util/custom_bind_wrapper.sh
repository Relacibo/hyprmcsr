#!/bin/bash
UTIL_DIR=$(dirname "${BASH_SOURCE[0]}")
export SCRIPT_DIR=$(realpath "$UTIL_DIR/../scripts")
source "$UTIL_DIR/env_prism.sh"
source "$UTIL_DIR/env_runtime.sh"
source "$UTIL_DIR/export_env.sh"

[ "$BINDS_ENABLED" = "1" ] || exit 0

BIND="${1:-}"
[ -z "$BIND" ] && exit 0

CMDS_JSON=$(jq -c --arg bind "$BIND" '.binds.custom[$bind] // empty' "$PROFILE_CONFIG_FILE")
[ -z "$CMDS_JSON" ] && exit 0

printf '%s' "$CMDS_JSON" | jq -r '
  if type == "array" then .[]
  elif type == "string" then .
  else empty
  end
' | while IFS= read -r cmd; do
  [ -z "$cmd" ] && continue
  bash -c "$cmd" &
done
