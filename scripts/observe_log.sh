#!/bin/bash

export SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")
source "$SCRIPT_DIR/../util/env_prism.sh"

LOGFILE="$MINECRAFT_ROOT/logs/latest.log"

# Robuste Überwachung, auch wenn die Logdatei neu erstellt wird
tail_loop() {
  while true; do
    if [[ -f "$LOGFILE" ]]; then
      tail -F "$LOGFILE" | while read -r line; do
        if [[ "$line" == *"StateOutput State: wall"* ]]; then
          "$SCRIPT_DIR/toggle_mode.sh" normal
          "$SCRIPT_DIR/toggle_binds.sh" 0
        elif [[ "$line" == *"StateOutput State: waiting"* ]]; then
          "$SCRIPT_DIR/toggle_mode.sh" normal
          "$SCRIPT_DIR/toggle_binds.sh" 1
        fi
      done
    else
      sleep 1
    fi
    # Kurze Pause, falls tail beendet wurde (z.B. bei Log-Rotation)
    sleep 1
  done
}

tail_loop
