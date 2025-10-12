#!/bin/sh

export SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")
source "$SCRIPT_DIR/../util/env_prism.sh"

# Wait for MINECRAFT_ROOT being set (max. 20 seconds)
tries=0
while [ -z "$MINECRAFT_ROOT" ] && [ "$tries" -lt 20 ]; do
  sleep 1
  . "$SCRIPT_DIR/../util/env_prism.sh"
  tries=$((tries + 1))
done

if [ -z "$MINECRAFT_ROOT" ]; then
  echo "MINECRAFT_ROOT could not be set."
  exit 1
fi

STATEFILE="$MINECRAFT_ROOT/wpstateout.txt"
LAST_STATE=""
LAST_MTIME=0

echo "Monitoring state file: $STATEFILE"

while true; do
  if [ -f "$STATEFILE" ]; then
    M_TIME=$(stat -c %Y "$STATEFILE" 2>/dev/null || echo 0)
    if [ "$M_TIME" -ne "$LAST_MTIME" ]; then
      LAST_MTIME=$M_TIME
      current_state=$(cat "$STATEFILE" 2>/dev/null)
      if [ "$current_state" != "$LAST_STATE" ]; then
        echo "State changed to: $current_state"
        LAST_STATE="$current_state"

        case "$current_state" in
          wall)
            "$SCRIPT_DIR/toggle_binds.sh" 0
            "$SCRIPT_DIR/toggle_mode.sh" normal
            ;;
          generating*)
            "$SCRIPT_DIR/toggle_binds.sh" 1
            "$SCRIPT_DIR/toggle_mode.sh" normal
            ;;
        esac
      fi
    fi
  fi
  sleep 0.05
done
