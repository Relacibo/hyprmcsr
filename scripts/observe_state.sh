#!/bin/sh

export SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")
source "$SCRIPT_DIR/../util/env_prism.sh"

# Wait for MINECRAFT_ROOT being set (max. 10 seconds)
tries=0
while [ -z "$MINECRAFT_ROOT" ] && [ "$tries" -lt 10 ]; do
    sleep 1
    source "$SCRIPT_DIR/../util/env_prism.sh"
    tries=$((tries + 1))
done

if [ -z "$MINECRAFT_ROOT" ]; then
    echo "[hyprmcsr] Warning: MINECRAFT_ROOT could not be set after ${tries}s timeout"
    exit 1
fi

STATE_FILE="$MINECRAFT_ROOT/wpstateout.txt"
LAST_STATE=""

echo "[hyprmcsr] Observing state file: $STATE_FILE"

# Wait for state file to exist (no timeout)
if [ ! -f "$STATE_FILE" ]; then
    echo "[hyprmcsr] Waiting for state file to be created..."
    while [ ! -f "$STATE_FILE" ]; do
        sleep 1
    done
    echo "[hyprmcsr] State file found"
fi

inotifywait -m -q -e modify "$STATE_FILE" 2>/dev/null | while read path action file; do
    current_state=$(cat "$STATE_FILE" 2>/dev/null)
    if [ "$current_state" != "$LAST_STATE" ]; then
        LAST_STATE="$current_state"
        echo "[hyprmcsr] State changed to: $current_state"
        case "$current_state" in
            wall)
                "$SCRIPT_DIR/toggle_mode.sh" normal
                "$SCRIPT_DIR/toggle_binds.sh" 0
                "$SCRIPT_DIR/../util/center_cursor.sh"
            ;;
            generating,0)
                "$SCRIPT_DIR/toggle_mode.sh" normal
                "$SCRIPT_DIR/toggle_binds.sh" 1
            ;;
            inworld,paused | inworld,gamescreenopen)
                "$SCRIPT_DIR/../util/center_cursor.sh"
            ;;
        esac
    fi
    
done
