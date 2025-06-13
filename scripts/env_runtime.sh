#!/bin/bash
source "$(dirname "$(realpath "$0")")/env_core.sh"

WINDOW_ADDRESS_FILE="$STATE_DIR/window_address"
if [ -f "$WINDOW_ADDRESS_FILE" ]; then
  WINDOW_ADDRESS=$(cat "$WINDOW_ADDRESS_FILE")
else
  WINDOW_ADDRESS=""
fi
export WINDOW_ADDRESS

CURRENT_MODE_FILE="$STATE_DIR/current_mode"
if [ -f "$CURRENT_MODE_FILE" ]; then
  CURRENT_MODE=$(cat "$CURRENT_MODE_FILE")
else
  CURRENT_MODE=""
fi
export CURRENT_MODE

BINDS_ENABLED_FILE="$STATE_DIR/binds_enabled"
if [ -f "$BINDS_ENABLED_FILE" ]; then
  BINDS_ENABLED=$(cat "$BINDS_ENABLED_FILE")
else
  BINDS_ENABLED="0"
fi
export BINDS_ENABLED
