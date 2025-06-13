#!/bin/bash
source "$(dirname "$(realpath "$0")")/env_setup.sh"

MODE="$1"
STATE_FILE="$STATE_DIR/window_switcher_state"
WINDOW_ADDRESS=$(cat "$STATE_DIR/window_address" 2>/dev/null || echo "")

BINDS_ENABLED_FILE="$STATE_DIR/binds_enabled"
[ "$(cat "$BINDS_ENABLED_FILE" 2>/dev/null || echo 0)" = "1" ] || exit 0

if ! command -v jq >/dev/null; then
  echo "jq is required!"
  exit 1
fi

if [ -z "$MODE" ]; then
  echo "Usage: $0 [normal|tall|boat-eye|planar-abuse]"
  exit 1
fi

# Read current state
CURRENT_STATE=""
[ -f "$STATE_FILE" ] && CURRENT_STATE=$(cat "$STATE_FILE")

# Toggle to normal if already in this mode
if [ "$CURRENT_STATE" = "$MODE" ]; then
  NEXT_MODE="normal"
else
  NEXT_MODE="$MODE"
fi

PREVIOUS_MODE="$CURRENT_STATE"

# Load target values (with fallback to default)
TARGET_SIZE=$(jq -r --arg m "$NEXT_MODE" '.modeSwitch.modes[$m].size // .modeSwitch.default.size' "$CONFIG_FILE")
TARGET_SENSITIVITY=$(jq -r --arg m "$NEXT_MODE" '.modeSwitch.modes[$m].sensitivity // .modeSwitch.default.sensitivity' "$CONFIG_FILE")

# onExit: run all commands in array (if any and mode changes)
if [ -n "$PREVIOUS_MODE" ] && [ "$PREVIOUS_MODE" != "$NEXT_MODE" ]; then
  (
    export WINDOW_ADDRESS SCRIPT_DIR HYPRMCSR_PROFILE PRISM_INSTANCE_ID MINECRAFT_ROOT PREVIOUS_MODE NEXT_MODE
    jq -r --arg m "$PREVIOUS_MODE" '.modeSwitch.modes[$m].onExit[]? // .modeSwitch.default.onExit[]? // empty' "$CONFIG_FILE" | while IFS= read -r cmd; do
      [ -z "$cmd" ] && continue
      bash -c "$cmd" &
    done
  )
fi

# Update state
echo "$NEXT_MODE" > "$STATE_FILE"

# Split size (e.g. 1920x1080)
IFS="x" read -r TARGET_WIDTH TARGET_HEIGHT <<< "$TARGET_SIZE"

# Set window size and sensitivity
hyprctl --batch "
  dispatch focuswindow address:$WINDOW_ADDRESS;
  dispatch setfloating;
  dispatch resizewindowpixel exact $TARGET_WIDTH $TARGET_HEIGHT,address:$WINDOW_ADDRESS;
  dispatch centerwindow address:$WINDOW_ADDRESS;
  keyword input:sensitivity $TARGET_SENSITIVITY;
  dispatch focuswindow address:$WINDOW_ADDRESS
"

PROFILE=$(cat "$STATE_DIR/profile" 2>/dev/null || echo "default")
# onEnter: run all commands in array (if any and mode changes)
if [ "$PREVIOUS_MODE" != "$NEXT_MODE" ]; then
  (
    export WINDOW_ADDRESS SCRIPT_DIR PROFILE HYPRMCSR_PROFILE PRISM_INSTANCE_ID MINECRAFT_ROOT PREVIOUS_MODE NEXT_MODE
    jq -r --arg m "$NEXT_MODE" '.modeSwitch.modes[$m].onEnter[]? // .modeSwitch.default.onEnter[]? // empty' "$CONFIG_FILE" | while IFS= read -r cmd; do
      [ -z "$cmd" ] && continue
      bash -c "$cmd" &
    done
  )
fi
