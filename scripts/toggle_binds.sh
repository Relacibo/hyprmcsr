#!/bin/bash
# filepath: /home/reinhard/git/hyprmcsr/scripts/toggle_binds.sh

source "$(dirname "$(realpath "$0")")/env_runtime.sh"

if [ $# -ge 1 ]; then
  # Argument als Wert setzen (nur 0 oder 1 zulassen)
  if [ "$1" = "0" ] || [ "$1" = "1" ]; then
    BINDS_ENABLED="$1"
  else
    echo "Ungültiges Argument: $1 (nur 0 oder 1 erlaubt)"
    exit 1
  fi
else
  # Toggle-Modus
  if [ "$BINDS_ENABLED" = "1" ]; then
    BINDS_ENABLED=0
  else
    BINDS_ENABLED=1
  fi
fi

echo "$BINDS_ENABLED" > "$STATE_DIR/binds_enabled"

# onToggleBinds ausführen (mit allen relevanten Umgebungsvariablen inkl. BINDS_ENABLED)
on_toggle_cmds=$(jq -r '.onToggleBinds[]?' "$CONFIG_FILE")
if [ -n "$on_toggle_cmds" ]; then
  export SCRIPT_DIR HYPRMCSR_PROFILE PRISM_INSTANCE_ID MINECRAFT_ROOT WINDOW_ADDRESS BINDS_ENABLED
  while IFS= read -r cmd; do
    bash -c "$cmd" &
  done <<< "$on_toggle_cmds"
fi
