#!/bin/bash

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "$SCRIPT_DIR/env_prism.sh"

LOGFILE="$MINECRAFT_ROOT/logs/latest.log"

tail -F "$LOGFILE" | while read -r line; do
  if [[ "$line" == *"StateOutput State: wall"* ]]; then
    "$SCRIPT_DIR/toggle_mode.sh" normal
    "$SCRIPT_DIR/toggle_binds.sh" 0
  elif [[ "$line" == *"StateOutput State: waiting"* ]]; then
    "$SCRIPT_DIR/toggle_mode.sh" normal
    "$SCRIPT_DIR/toggle_binds.sh" 1
  fi
done
