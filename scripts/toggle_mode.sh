#!/bin/bash

export XDG_RUNTIME_DIR="/run/user/$(id -u)"

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
CONFIG_FILE="$SCRIPT_DIR/../config.json"
MODE="$1"
STATE_FILE="$SCRIPT_DIR/../var/window_switcher_state"
WINDOW_ADDRESS=$(cat "$SCRIPT_DIR/../var/window_address")

BINDS_ENABLED_FILE="$SCRIPT_DIR/../var/binds_enabled"
[ "$(cat "$BINDS_ENABLED_FILE" 2>/dev/null || echo 0)" = "1" ] || exit 0

if ! command -v jq >/dev/null; then
  echo "jq wird benötigt!"
  exit 1
fi

if [ -z "$MODE" ]; then
  echo "Usage: $0 [normal|tall|boat-eye|planar-abuse]"
  exit 1
fi

# Aktuellen State lesen
CURRENT_STATE=""
[ -f "$STATE_FILE" ] && CURRENT_STATE=$(cat "$STATE_FILE")

# Wenn der gewünschte Modus bereits aktiv ist, auf "normal" zurückschalten
if [ "$CURRENT_STATE" = "$MODE" ]; then
  NEXT_MODE="normal"
else
  NEXT_MODE="$MODE"
fi

PREVIOUS_MODE="$CURRENT_STATE"

# Werte für den Zielmodus laden (mit Fallback auf default)
# Beispiel für size und sensitivity:
TARGET_SIZE=$(jq -r --arg m "$NEXT_MODE" '.modeSwitch.modes[$m].size // .modeSwitch.default.size' "$CONFIG_FILE")
TARGET_SENSITIVITY=$(jq -r --arg m "$NEXT_MODE" '.modeSwitch.modes[$m].sensitivity // .modeSwitch.default.sensitivity' "$CONFIG_FILE")
ON_ENTER=$(jq -r --arg m "$NEXT_MODE" '.modeSwitch.modes[$m].onEnter // .modeSwitch.default.onEnter // empty' "$CONFIG_FILE")
ON_EXIT=$(jq -r --arg m "$PREVIOUS_MODE" '.modeSwitch.modes[$m].onExit // .modeSwitch.default.onExit // empty' "$CONFIG_FILE")

# onExit des aktuellen Modus ausführen (falls vorhanden und Moduswechsel)
if [ -n "$PREVIOUS_MODE" ] && [ "$PREVIOUS_MODE" != "$NEXT_MODE" ]; then
  if [ -n "$ON_EXIT" ]; then
    SCRIPT_DIR="$SCRIPT_DIR" PREVIOUS_MODE="$PREVIOUS_MODE" NEXT_MODE="$NEXT_MODE" bash -c "$ON_EXIT"
  fi
fi

# State aktualisieren
echo "$NEXT_MODE" > "$STATE_FILE"

# onEnter des neuen Modus ausführen (falls vorhanden und Moduswechsel)
if [ "$PREVIOUS_MODE" != "$NEXT_MODE" ]; then
  if [ -n "$ON_ENTER" ]; then
    SCRIPT_DIR="$SCRIPT_DIR" PREVIOUS_MODE="$PREVIOUS_MODE" NEXT_MODE="$NEXT_MODE" bash -c "$ON_ENTER"
  fi
fi

# Größe aus wxh in w und h splitten
IFS="x" read -r TARGET_WIDTH TARGET_HEIGHT <<< "$TARGET_SIZE"

# Fenstergröße und Sensitivity setzen
hyprctl --batch "
  dispatch focuswindow address:$WINDOW_ADDRESS;
  dispatch setfloating;
  dispatch resizewindowpixel exact $TARGET_WIDTH $TARGET_HEIGHT,address:$WINDOW_ADDRESS;
  dispatch centerwindow address:$WINDOW_ADDRESS;
  keyword input:sensitivity $TARGET_SENSITIVITY;
  dispatch focuswindow address:$WINDOW_ADDRESS
"
