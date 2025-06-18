#!/bin/bash

CONFIG_ROOT="${XDG_CONFIG_HOME:-$HOME/.config}/hyprmcsr"
mkdir -p "$CONFIG_ROOT"

HYPRMCSR_PROFILE="${HYPRMCSR_PROFILE:-default}"
PROFILE_CONFIG_FILE="$CONFIG_ROOT/${HYPRMCSR_PROFILE}.profile.json"
CONFIG_FILE="$CONFIG_ROOT/config.json"

if [ -n "$XDG_RUNTIME_DIR" ]; then
  STATE_DIR="$XDG_RUNTIME_DIR/hyprmcsr/$HYPRMCSR_PROFILE"
else
  STATE_DIR="/tmp/hyprmcsr-$USER/$HYPRMCSR_PROFILE"
fi
mkdir -p "$STATE_DIR"

HYPRMCSR_BIN=$(realpath "$SCRIPT_DIR/../bin/hyprmcsr")

export CONFIG_ROOT
export HYPRMCSR_PROFILE
export CONFIG_FILE
export PROFILE_CONFIG_FILE
export STATE_DIR
export HYPRMCSR_BIN
