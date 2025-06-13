#!/bin/bash
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "$SCRIPT_DIR/env_runtime.sh"
source "$SCRIPT_DIR/env_prism.sh"

MODE="$1"
STATE_FILE="$STATE_DIR/current_mode"

[ "$BINDS_ENABLED" = "1" ] || exit 0

if ! command -v jq >/dev/null; then
  echo "jq is required!"
  exit 1
fi

if [ -z "$MODE" ]; then
  echo "Usage: $0 [normal|tall|boat-eye|planar-abuse]"
  exit 1
fi

# Toggle to normal if already in this mode
if [ "$CURRENT_MODE" = "$MODE" ]; then
  NEXT_MODE="normal"
else
  NEXT_MODE="$MODE"
fi

PREVIOUS_MODE="$CURRENT_MODE"

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
