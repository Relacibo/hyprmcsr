#!/bin/bash

CONFIG_ROOT="${XDG_CONFIG_HOME:-$HOME/.config}/hyprmcsr"
mkdir -p "$CONFIG_ROOT"

HYPRMCSR_PROFILE="${HYPRMCSR_PROFILE:-default}"
PROFILE_CONFIG_FILE="$CONFIG_ROOT/${HYPRMCSR_PROFILE}.profile.json"
CONFIG_FILE="$CONFIG_ROOT/config.json"

# STATE_DIR aus profile config lesen, falls vorhanden (jq und Profil-Datei werden vorausgesetzt)
STATE_DIR=$(jq -r '.stateDir // empty' "$PROFILE_CONFIG_FILE")

if [ -z "$STATE_DIR" ]; then
    STATE_DIR="/tmp/hyprmcsr-$USER/$HYPRMCSR_PROFILE"
fi

mkdir -p "$STATE_DIR"

HYPRMCSR=$(realpath "$SCRIPT_DIR/../bin/hyprmcsr")

export CONFIG_ROOT
export HYPRMCSR_PROFILE
export CONFIG_FILE
export PROFILE_CONFIG_FILE
export STATE_DIR
export HYPRMCSR
