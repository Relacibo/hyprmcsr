#!/bin/bash

export XDG_RUNTIME_DIR="/run/user/$(id -u)"

SCRIPT_PATH="$(dirname $(realpath "$0"))"
CONFIG_FILE="$SCRIPT_PATH/../config.json"
MODE="$1"
STATE_FILE="$SCRIPT_PATH/../var/window_switcher_state"
WINDOW_ADDRESS_FILE="$SCRIPT_PATH/../var/window_address"

if ! command -v jq >/dev/null; then
  echo "jq wird benötigt!"
  exit 1
fi

if [ -z "$MODE" ]; then
  echo "Usage: $0 [tall|boat-eye|planar-abuse|default]"
  exit 1
fi

# Default-Werte laden
DEFAULT_SIZE=$(jq -r '.modeSwitch.default.size' "$CONFIG_FILE")
DEFAULT_SENSITIVITY=$(jq -r '.modeSwitch.default.sensitivity' "$CONFIG_FILE")

# Modus-Werte laden (können null sein)
TARGET_SIZE=$(jq -r --arg m "$MODE" '.modeSwitch[$m].size // empty' "$CONFIG_FILE")
TARGET_SENSITIVITY=$(jq -r --arg m "$MODE" '.modeSwitch[$m].sensitivity // empty' "$CONFIG_FILE")

# Fallback auf Default, falls leer
[ -z "$TARGET_SIZE" ] && TARGET_SIZE="$DEFAULT_SIZE"
[ -z "$TARGET_SENSITIVITY" ] && TARGET_SENSITIVITY="$DEFAULT_SENSITIVITY"

# Aktuellen State lesen
CURRENT_STATE=""
[ -f "$STATE_FILE" ] && CURRENT_STATE=$(cat "$STATE_FILE")

# Wenn der gewünschte Modus bereits aktiv ist, auf Default zurückschalten
if [ "$CURRENT_STATE" = "$MODE" ]; then
  TARGET_SIZE="$DEFAULT_SIZE"
  TARGET_SENSITIVITY="$DEFAULT_SENSITIVITY"
  NEXT_MODE="default"
else
  NEXT_MODE="$MODE"
fi

PREVIOUS_MODE="$CURRENT_STATE"

# onExit des aktuellen Modus ausführen (falls vorhanden und Moduswechsel)
if [ -n "$PREVIOUS_MODE" ] && [ "$PREVIOUS_MODE" != "$NEXT_MODE" ]; then
  ON_EXIT=$(jq -r --arg m "$PREVIOUS_MODE" '.modeSwitch[$m].onExit // empty' "$CONFIG_FILE")
  if [ -n "$ON_EXIT" ]; then
    PREVIOUS_MODE="$PREVIOUS_MODE" NEXT_MODE="$NEXT_MODE" "$ON_EXIT"
  fi
fi

# State aktualisieren
echo "$NEXT_MODE" > "$STATE_FILE"

# onEnter des neuen Modus ausführen (falls vorhanden und Moduswechsel)
if [ "$PREVIOUS_MODE" != "$NEXT_MODE" ]; then
  ON_ENTER=$(jq -r --arg m "$NEXT_MODE" '.modeSwitch[$m].onEnter // empty' "$CONFIG_FILE")
  if [ -n "$ON_ENTER" ]; then
    PREVIOUS_MODE="$PREVIOUS_MODE" NEXT_MODE="$NEXT_MODE" "$ON_ENTER"
  fi
fi

# Fensteradresse aus Datei lesen
if [ ! -f "$WINDOW_ADDRESS_FILE" ]; then
  echo "Fensteradresse nicht gefunden: $WINDOW_ADDRESS_FILE"
  exit 1
fi
WINDOW_ADDRESS=$(cat "$WINDOW_ADDRESS_FILE")

# Größe aus wxh in w und h splitten
IFS="x" read -r TARGET_WIDTH TARGET_HEIGHT <<< "$TARGET_SIZE"

# Fenstergröße und Sensitivity setzen
hyprctl --batch "
  dispatch focuswindow address:$WINDOW_ADDRESS;
  dispatch setfloating;
  dispatch resizewindowpixel exact $TARGET_WIDTH $TARGET_HEIGHT,address:$WINDOW_ADDRESS;
  dispatch centerwindow address:$WINDOW_ADDRESS;
  keyword input:sensitivity $TARGET_SENSITIVITY
"
