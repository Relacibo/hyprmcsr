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
LAST_SCREEN_CLASS=""

# Detect the state source via the mods folder instead of racing the two
# persistent files: if a hermes*.jar (excluding hermes-core) is installed,
# Hermes will write state.json once the game starts, so wait for it. On the
# first start after installing Hermes state.json does not exist yet while the
# legacy wpstateout.txt persists from a previous session - falling back to it
# would permanently pin the script to legacy mode for the whole session.
HERMES_JAR=$(ls "$MINECRAFT_ROOT/mods/"hermes-*.jar 2>/dev/null | grep -v "hermes-core" | head -n1)

STATE_FILE=""
MODE=""
if [ -n "$HERMES_JAR" ]; then
    echo "[hyprmcsr] Hermes detected ($(basename "$HERMES_JAR")), waiting for state.json"
    while [ ! -f "$HERMES_STATE_FILE" ]; do
        sleep 1
    done
    STATE_FILE="$HERMES_STATE_FILE"
    MODE="hermes"
else
    # No Hermes mod found: prefer state.json if it ever appears (installed
    # elsewhere), otherwise fall back to the legacy State Output file.
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
fi

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
# State machine mirrors Jingle's default "Extra Keys" script:
#   - world != null and screen is one of the loading screens -> world is loading
#   - world != null and screen == null                       -> in world
# Cursor centering follows vanilla behavior: the cursor is centered when a
# screen opens from gameplay (screen == null -> screen != null), not on
# screen to screen transitions (e.g. pause menu -> options).
handle_hermes_state() {
    parsed=$(printf '%s' "$1" | jq -e '.' 2>/dev/null) || return
    world=$(printf '%s' "$parsed" | jq -r '.world.path // empty' 2>/dev/null)
    screen_class=$(printf '%s' "$parsed" | jq -r '.screen.class // empty' 2>/dev/null)
    is_pause=$(printf '%s' "$parsed" | jq -r '.screen.is_pause // empty' 2>/dev/null)

    echo "[hyprmcsr] State changed: world=${world:-none} screen=${screen_class:-none} pause=${is_pause:-false}"

    # SeedQueue wall screen: normal mode, binds off. Centered explicitly -
    # the wall usually follows another screen, so the transition rule below
    # would not catch it.
    if [ "$screen_class" = "me.contaria.seedqueue.gui.wall.SeedQueueWallScreen" ]; then
        "$SCRIPT_DIR/toggle_mode.sh" normal
        "$SCRIPT_DIR/toggle_binds.sh" 0
        "$SCRIPT_DIR/../util/center_cursor.sh"
        LAST_SCREEN_CLASS="$screen_class"
    fi

    # World loading screens, matched by class and not by title (Jingle
    # approach): titles are unreliable, LevelLoadingScreen uses
    # menu.generatingTerrain or menu.loadingLevel depending on context and
    # DownloadingTerrainScreen has an empty title component.
    # 1.16.1 intermediary classes plus the official (unobfuscated) names.
    if [ -n "$world" ]; then
        case "$screen_class" in
            *.class_435 | *.class_3928 | *.class_434 | *.ProgressScreen | *.LevelLoadingScreen | *.ReceivingLevelScreen)
                "$SCRIPT_DIR/toggle_mode.sh" normal
                "$SCRIPT_DIR/toggle_binds.sh" 1
            ;;
        esac
    fi

    # In world with no screen open. Also acts as a safety net when rapid
    # state updates collapse and the loading screens are never observed.
    if [ -n "$world" ] && [ -z "$screen_class" ]; then
        "$SCRIPT_DIR/toggle_binds.sh" 1
    fi

    # Center the cursor when a screen opens from gameplay. Vanilla keeps the
    # cursor at the window center by warping it every frame while playing;
    # this does not happen on Hyprland/Wayland, so center manually. Screen
    # to screen transitions must not center.
    if [ -n "$screen_class" ] && [ -z "$LAST_SCREEN_CLASS" ]; then
        "$SCRIPT_DIR/../util/center_cursor.sh"
    fi
    LAST_SCREEN_CLASS="$screen_class"
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
