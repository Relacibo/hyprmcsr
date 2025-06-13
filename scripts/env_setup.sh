#!/bin/bash

SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"

CONFIG_ROOT="${XDG_CONFIG_HOME:-$HOME/.config}/hyprmcsr"
mkdir -p "$CONFIG_ROOT"

GLOBAL_CONFIG_FILE="$CONFIG_ROOT/config.json"
export GLOBAL_CONFIG_FILE

HYPRMCSR_PROFILE="${HYPRMCSR_PROFILE:-default}"
CONFIG_FILE="$CONFIG_ROOT/${HYPRMCSR_PROFILE}.profile.json"
export CONFIG_FILE

if [ -n "$XDG_RUNTIME_DIR" ]; then
  STATE_DIR="$XDG_RUNTIME_DIR/hyprmcsr/$HYPRMCSR_PROFILE"
else
  STATE_DIR="/tmp/hyprmcsr-$USER/$HYPRMCSR_PROFILE"
fi
mkdir -p "$STATE_DIR"

export HYPRMCSR_PROFILE
export STATE_DIR
export SCRIPT_DIR
