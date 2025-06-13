#!/bin/bash
SCRIPT_DIR=$(dirname "$(realpath "$0")")
VAR_DIR="$SCRIPT_DIR/../var"
BINDS_ENABLED_FILE="$VAR_DIR/binds_enabled"
WINDOW_ADDRESS=$(cat "$VAR_DIR/window_address" 2>/dev/null || echo "")
PROFILE=$(cat "$VAR_DIR/profile" 2>/dev/null || echo "default")

[ "$(cat "$BINDS_ENABLED_FILE" 2>/dev/null || echo 0)" = "1" ] || exit 0

# Das Array als JSON-String kommt als $1
CMDS_JSON="$1"
# Alle Kommandos ausführen
echo "$CMDS_JSON" | jq -r '.[]' | while IFS= read -r cmd; do
  [ -z "$cmd" ] && continue
  WINDOW_ADDRESS="$WINDOW_ADDRESS" SCRIPT_DIR="$SCRIPT_DIR" PROFILE="$PROFILE" bash -c "$cmd" &
done
