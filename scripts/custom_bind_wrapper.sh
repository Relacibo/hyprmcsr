#!/bin/bash
source "$(dirname "$(realpath "$0")")/env_setup.sh"

BINDS_ENABLED_FILE="$STATE_DIR/binds_enabled"
WINDOW_ADDRESS=$(cat "$STATE_DIR/window_address" 2>/dev/null || echo "")
PROFILE=$(cat "$STATE_DIR/profile" 2>/dev/null || echo "default")
PRISM_INSTANCE_ID=$(jq -r '.minecraft.prismInstanceId' "$CONFIG_FILE")
PRISM_PREFIX=$(jq -r '.minecraft.prismPrefixOverride // "~/.local/share/PrismLauncher"' "$CONFIG_FILE")
PRISM_PREFIX="${PRISM_PREFIX/#\~/$HOME}"
MINECRAFT_ROOT="$PRISM_PREFIX/instances/$PRISM_INSTANCE_ID/.minecraft"

[ "$(cat "$BINDS_ENABLED_FILE" 2>/dev/null || echo 0)" = "1" ] || exit 0

CMDS_JSON="$1"

(
  export WINDOW_ADDRESS SCRIPT_DIR PROFILE HYPRMCSR_PROFILE PRISM_INSTANCE_ID MINECRAFT_ROOT
  echo "$CMDS_JSON" | jq -r '.[]' | while IFS= read -r cmd; do
    [ -z "$cmd" ] && continue
    bash -c "$cmd" &
  done
)
