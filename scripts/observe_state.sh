#!/bin/sh

export SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")
source "$SCRIPT_DIR/../util/env_prism.sh"

# Wait for MINECRAFT_ROOT being set (max. 20 seconds)
tries=0
while [ -z "$MINECRAFT_ROOT" ] && [ "$tries" -lt 20 ]; do
    sleep 1
    source "$SCRIPT_DIR/../util/env_prism.sh"
    tries=$((tries + 1))
done

if [ -z "$MINECRAFT_ROOT" ]; then
    echo "MINECRAFT_ROOT could not be set."
fi

STATE_FILE="$MINECRAFT_ROOT/wpstateout.txt"
LAST_STATE=""

inotifywait -m -q -e modify "$STATE_FILE" | while read path action file; do
    current_state=$(cat "$STATE_FILE" 2>/dev/null)
    if [ "$current_state" != "$LAST_STATE" ]; then
        LAST_STATE="$current_state"
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
