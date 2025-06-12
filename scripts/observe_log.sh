#!/bin/bash
# Logfile der Prism-Instanz bestimmen
SCRIPT_DIR=$(dirname $(realpath "$0"))
CONFIG_FILE="$SCRIPT_DIR/../config.json"
PRISM_INSTANCE_ID=$(jq -r '.minecraft.prismInstanceId' "$CONFIG_FILE")
LOGFILE="$HOME/.local/share/PrismLauncher/instances/$PRISM_INSTANCE_ID/.minecraft/logs/latest.log"

tail -F "$LOGFILE" | while read -r line; do
  if [[ "$line" == *"StateOutput State: wall"* ]]; then
    $SCRIPT_DIR/toggle_mode.sh normal
    $SCRIPT_DIR/toggle_binds.sh 0
  elif [[ "$line" == *"StateOutput State: inworld,unpaused"* ]]; then
    $SCRIPT_DIR/toggle_binds.sh 1
  fi
done
