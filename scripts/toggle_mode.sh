#!/bin/bash
export SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")
UTIL_DIR="$SCRIPT_DIR/../util"
source "$UTIL_DIR/env_core.sh"
source "$UTIL_DIR/env_prism.sh"
source "$UTIL_DIR/env_runtime.sh"
source "$UTIL_DIR/hypr_compat.sh"

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

if [ -z "$WINDOW_ADDRESS" ] || ! hyprctl clients -j | jq -e --arg addr "$WINDOW_ADDRESS" '.[] | select(.address == $addr)' >/dev/null 2>&1; then
  echo "[hyprmcsr] Minecraft window not found; skipping mode switch to '$MODE'." >&2
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

if [ -z "$TARGET_SIZE" ] || [ "$TARGET_SIZE" = "null" ]; then
  echo "[hyprmcsr] No size configured for mode '$NEXT_MODE' and no default size." >&2
  exit 1
fi

MONITOR_ID=$(hyprctl clients -j | jq -r --arg addr "$WINDOW_ADDRESS" '.[] | select(.address == $addr) | .monitor')

# Handle fullscreen size
if [ "$TARGET_SIZE" = "fullscreen" ]; then
  read -r WIDTH HEIGHT SCALE <<< "$(hyprctl monitors -j | jq -r --arg mid "$MONITOR_ID" '.[] | select((.id | tostring) == $mid) | "\(.width) \(.height) \(.scale)"')"
  if [ -z "$WIDTH" ] || [ -z "$HEIGHT" ] || [ -z "$SCALE" ]; then
    echo "[hyprmcsr] Could not determine the size of monitor '$MONITOR_ID'." >&2
    exit 1
  fi
  TARGET_WIDTH=$(awk "BEGIN {printf \"%.0f\", $WIDTH / $SCALE}")
  TARGET_HEIGHT=$(awk "BEGIN {printf \"%.0f\", $HEIGHT / $SCALE}")
else
  # Split size (e.g. 1920x1080)
  IFS="x" read -r TARGET_WIDTH TARGET_HEIGHT <<< "$TARGET_SIZE"
fi

if ! [[ "$TARGET_WIDTH" =~ ^[0-9]+$ && "$TARGET_HEIGHT" =~ ^[0-9]+$ ]]; then
  echo "[hyprmcsr] Invalid size '$TARGET_SIZE' for mode '$NEXT_MODE'." >&2
  exit 1
fi

# Omit the sensitivity update when no value is configured; an empty or
# literal "null" value would otherwise be passed to Hyprland.
SET_SENSITIVITY="0"
if [ -n "$TARGET_SENSITIVITY" ] && [ "$TARGET_SENSITIVITY" != "null" ]; then
  SET_SENSITIVITY="1"
fi

# Run onExit: run all commands in array (only if PREVIOUS_MODE is set)
if [ -n "$PREVIOUS_MODE" ]; then
  jq -c --arg m "$PREVIOUS_MODE" '.modeSwitch.modes[$m].onExit[]? // .modeSwitch.default.onExit[]? // empty' "$PROFILE_CONFIG_FILE" | while IFS= read -r cmd; do
    [ -z "$cmd" ] && continue
    "$SCRIPT_DIR/../util/run_conditional_command.sh" "$cmd"
  done
fi

# Update state
echo "$NEXT_MODE" > "$STATE_FILE"

# Set window size and sensitivity
hypr_focus_window "$WINDOW_ADDRESS"
hypr_resize_window "$WINDOW_ADDRESS" "$TARGET_WIDTH" "$TARGET_HEIGHT"
hypr_center_window "$WINDOW_ADDRESS"
[ "$SET_SENSITIVITY" = "1" ] && hypr_set_sensitivity "$TARGET_SENSITIVITY"
hypr_focus_window "$WINDOW_ADDRESS"
LAST_MONITOR_FILE="$STATE_DIR/last_monitor"

if [ -n "$MONITOR_ID" ]; then
  read -r LAST_MONITOR 2>/dev/null < "$LAST_MONITOR_FILE" || LAST_MONITOR=""
  [ "$LAST_MONITOR" != "$MONITOR_ID" ] && echo "$MONITOR_ID" > "$LAST_MONITOR_FILE"
fi


# Run onEnter: run all commands in array
export WINDOW_ADDRESS HYPRMCSR_PROFILE PRISM_INSTANCE_ID MINECRAFT_ROOT PREVIOUS_MODE NEXT_MODE
jq -c --arg m "$NEXT_MODE" '.modeSwitch.modes[$m].onEnter[]? // .modeSwitch.default.onEnter[]? // empty' "$PROFILE_CONFIG_FILE" | while IFS= read -r cmd; do
  [ -z "$cmd" ] && continue
  "$SCRIPT_DIR/../util/run_conditional_command.sh" "$cmd"
done
