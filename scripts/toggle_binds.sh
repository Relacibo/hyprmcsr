#!/bin/bash
source "$(dirname "$(realpath "$0")")/env_runtime.sh"

if [ $# -ge 1 ]; then
  # Argument als Wert setzen (nur 0 oder 1 zulassen)
  if [ "$1" = "0" ] || [ "$1" = "1" ]; then
    echo "$1" > "$STATE_DIR/binds_enabled"
    exit 0
  else
    echo "Ungültiges Argument: $1 (nur 0 oder 1 erlaubt)"
    exit 1
  fi
fi

# Toggle-Modus
if [ "$BINDS_ENABLED" = "1" ]; then
  echo 0 > "$STATE_DIR/binds_enabled"
else
  echo 1 > "$STATE_DIR/binds_enabled"
fi
