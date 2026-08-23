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

HERMES_STATE_FILE="$MINECRAFT_ROOT/hermes/state.json"
LEGACY_STATE_FILE="$MINECRAFT_ROOT/wpstateout.txt"
LAST_STATE=""

# Prefer Hermes state.json, fall back to the legacy State Output file (wpstateout.txt)
STATE_FILE=""
MODE=""
while [ -z "$STATE_FILE" ]; do
    if [ -f "$HERMES_STATE_FILE" ]; then
        STATE_FILE="$HERMES_STATE_FILE"
        MODE="hermes"
    elif [ -f "$LEGACY_STATE_FILE" ]; then
        STATE_FILE="$LEGACY_STATE_FILE"
        MODE="legacy"
    else
        sleep 1
    fi
done

echo "[hyprmcsr] Observing state file ($MODE): $STATE_FILE"

handle_state() {
    current_state=$(cat "$STATE_FILE" 2>/dev/null)
    if [ "$current_state" != "$LAST_STATE" ]; then
        LAST_STATE="$current_state"

        if [ "$MODE" = "hermes" ]; then
            handle_hermes_state "$current_state"
        else
            handle_legacy_state "$current_state"
        fi
    fi
}

# Hermes state.json contains raw data without interpretation. Derive the
# states the session automation cares about with jq.
# Mod screen class names (e.g. SeedQueue) are stable, vanilla screens use
# intermediary class names and are matched by their title key instead.
handle_hermes_state() {
    parsed=$(printf '%s' "$1" | jq -e '.' 2>/dev/null) || return
    world=$(printf '%s' "$parsed" | jq -r '.world.path // empty' 2>/dev/null)
    screen_class=$(printf '%s' "$parsed" | jq -r '.screen.class // empty' 2>/dev/null)
    screen_title=$(printf '%s' "$parsed" | jq -r '.screen.title | if type == "object" then (.translate // empty) else empty end' 2>/dev/null)
    is_pause=$(printf '%s' "$parsed" | jq -r '.screen.is_pause // empty' 2>/dev/null)

    echo "[hyprmcsr] State changed: world=${world:-none} screen=${screen_class:-none} pause=${is_pause:-false}"

    # SeedQueue wall screen
    if [ "$screen_class" = "me.contaria.seedqueue.gui.wall.SeedQueueWallScreen" ]; then
        "$SCRIPT_DIR/toggle_mode.sh" normal
        "$SCRIPT_DIR/toggle_binds.sh" 0
        "$SCRIPT_DIR/../util/center_cursor.sh"
        return
    fi

    # World generating/loading (LevelLoadingScreen / DownloadingTerrainScreen)
    # DownloadingTerrainScreen has an empty title component, so it can only be
    # matched by its intermediary class name (1.16.1: class_434).
    if [ "$screen_title" = "menu.generatingTerrain" ] || [ "$screen_class" = "net.minecraft.class_434" ]; then
        "$SCRIPT_DIR/toggle_mode.sh" normal
        "$SCRIPT_DIR/toggle_binds.sh" 1
        return
    fi

    # Pause screen or any other game screen open while in world
    if [ -n "$world" ] && { [ "$is_pause" = "true" ] || [ -n "$screen_class" ]; }; then
        "$SCRIPT_DIR/../util/center_cursor.sh"
    fi
}

handle_legacy_state() {
    echo "[hyprmcsr] State changed to: $1"
    case "$1" in
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
}

# React to the current state once before watching for changes
handle_state

inotifywait -m -q -e modify "$STATE_FILE" 2>/dev/null | while read path action file; do
    handle_state
done
