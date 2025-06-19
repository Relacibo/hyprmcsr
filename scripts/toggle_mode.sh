#!/bin/bash
export SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")
# env_runtime.sh, env_core.sh und env_prism.sh werden jetzt alle aus util/ bezogen
source "$SCRIPT_DIR/../util/env_core.sh"
source "$SCRIPT_DIR/../util/env_prism.sh"
source "$SCRIPT_DIR/../util/env_runtime.sh"

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

# If mode does not change, exit script
if [ "$PREVIOUS_MODE" = "$NEXT_MODE" ]; then
  exit 0
fi

# Load target values (with fallback to default)
TARGET_SIZE=$(jq -r --arg m "$NEXT_MODE" '.modeSwitch.modes[$m].size // .modeSwitch.default.size' "$PROFILE_CONFIG_FILE")
TARGET_SENSITIVITY=$(jq -r --arg m "$NEXT_MODE" '.modeSwitch.modes[$m].sensitivity // .modeSwitch.default.sensitivity' "$PROFILE_CONFIG_FILE")

# Run onExit: run all commands in array (only if PREVIOUS_MODE is set)
if [ -n "$PREVIOUS_MODE" ]; then
  jq -c --arg m "$PREVIOUS_MODE" '.modeSwitch.modes[$m].onExit[]? // .modeSwitch.default.onExit[]? // empty' "$PROFILE_CONFIG_FILE" | while IFS= read -r cmd; do
    [ -z "$cmd" ] && continue
    "$SCRIPT_DIR/../util/run_conditional_command.sh" "$cmd"
  done
fi

# Update state
echo "$NEXT_MODE" > "$STATE_FILE"

# Split size (e.g. 1920x1080)
IFS="x" read -r TARGET_WIDTH TARGET_HEIGHT <<< "$TARGET_SIZE"

# Set window size and sensitivity
hyprctl --batch "
  dispatch resizewindowpixel exact $TARGET_WIDTH $TARGET_HEIGHT,address:$WINDOW_ADDRESS;
  dispatch centerwindow address:$WINDOW_ADDRESS;
  keyword input:sensitivity $TARGET_SENSITIVITY;
  dispatch focuswindow address:$WINDOW_ADDRESS
"

# Run onEnter: run all commands in array
export WINDOW_ADDRESS HYPRMCSR_PROFILE PRISM_INSTANCE_ID MINECRAFT_ROOT PREVIOUS_MODE NEXT_MODE
jq -c --arg m "$NEXT_MODE" '.modeSwitch.modes[$m].onEnter[]? // .modeSwitch.default.onEnter[]? // empty' "$PROFILE_CONFIG_FILE" | while IFS= read -r cmd; do
  [ -z "$cmd" ] && continue
  "$SCRIPT_DIR/../util/run_conditional_command.sh" "$cmd"
done
