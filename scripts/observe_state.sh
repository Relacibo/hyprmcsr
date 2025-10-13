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
USE_INOTIFYWAIT=$(jq -r '.minecraft.observeState.useInotifywait' "$PROFILE_CONFIG_FILE")
LAST_STATE=""

if [ "$USE_INOTIFYWAIT" = "true" ]; then
    if ! command -v inotifywait >/dev/null 2>&1; then
        echo "inotifywait not found. Falling back to polling."
        USE_INOTIFYWAIT="false"
    fi
fi

if [ "$USE_INOTIFYWAIT" != "true" ]; then
    # doesn't work 100% reliably, better use inotifywait if possible
    LAST_MTIME=0
    while true; do
        
        if [ -f "$STATE_FILE" ]; then
            M_TIME=$(stat -c %Y "$STATE_FILE" 2>/dev/null || echo 0)
            if [ "$M_TIME" -ne "$LAST_MTIME" ]; then
                LAST_MTIME=$M_TIME
                current_state=$(cat "$STATE_FILE" 2>/dev/null)
                if [ "$current_state" != "$LAST_STATE" ]; then
                    LAST_STATE="$current_state"
                    case "$current_state" in
                        wall)
                            "$SCRIPT_DIR/toggle_mode.sh" normal
                            "$SCRIPT_DIR/toggle_binds.sh" 0
                        ;;
                        generating*)
                            "$SCRIPT_DIR/toggle_mode.sh" normal
                            "$SCRIPT_DIR/toggle_binds.sh" 1
                        ;;
                    esac
                fi
            fi
        fi
        sleep 0.05
    done
    
else
    inotifywait -m -q -e modify "$STATE_FILE" | while read path action file; do
        current_state=$(cat "$STATE_FILE" 2>/dev/null)
        if [ "$current_state" != "$LAST_STATE" ]; then
            LAST_STATE="$current_state"
            case "$current_state" in
                wall)
                    "$SCRIPT_DIR/toggle_mode.sh" normal
                    "$SCRIPT_DIR/toggle_binds.sh" 0
                ;;
                generating,0)
                    "$SCRIPT_DIR/toggle_mode.sh" normal
                    "$SCRIPT_DIR/toggle_binds.sh" 1
                ;;
            esac
        fi
    done
fi
