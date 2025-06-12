#!/bin/bash
SCRIPT_DIR=$(dirname "$(realpath "$0")")
VAR_DIR="$SCRIPT_DIR/../var"
BINDS_ENABLED_FILE="$VAR_DIR/binds_enabled"

if [ $# -ge 1 ]; then
  # Argument als Wert setzen (nur 0 oder 1 zulassen)
  if [ "$1" = "0" ] || [ "$1" = "1" ]; then
    echo "$1" > "$BINDS_ENABLED_FILE"
    exit 0
  else
    echo "Ungültiges Argument: $1 (nur 0 oder 1 erlaubt)"
    exit 1
  fi
fi

# Toggle-Modus
binds_enabled=$(cat "$BINDS_ENABLED_FILE" 2>/dev/null || echo 0)
if [ "$binds_enabled" = "1" ]; then
  echo 0 > "$BINDS_ENABLED_FILE"
else
  echo 1 > "$BINDS_ENABLED_FILE"
fi
