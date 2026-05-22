#!/bin/bash

CONFIG_ROOT="${XDG_CONFIG_HOME:-$HOME/.config}/hyprmcsr"
mkdir -p "$CONFIG_ROOT"

HYPRMCSR_PROFILE="${HYPRMCSR_PROFILE:-default}"
PROFILE_CONFIG_FILE="$CONFIG_ROOT/${HYPRMCSR_PROFILE}.profile.json"
REPOSITORIES_FILE="$CONFIG_ROOT/repositories.json"

# Read STATE_DIR from profile config if present (requires jq and profile file)
STATE_DIR=$(jq -r '.stateDir // empty' "$PROFILE_CONFIG_FILE")

if [ -z "$STATE_DIR" ]; then
    BASE_DIR="${XDG_RUNTIME_DIR:-/run/user/$UID}"
    
    if [ -d "$BASE_DIR" ] && [ -w "$BASE_DIR" ]; then
        STATE_DIR="$BASE_DIR/hyprmcsr/profile/$HYPRMCSR_PROFILE"
    else
        STATE_DIR="/tmp/hyprmcsr-$UID/profile/$HYPRMCSR_PROFILE"
    fi
fi

mkdir -p "$STATE_DIR"

HYPRMCSR=$(realpath "$SCRIPT_DIR/../bin/hyprmcsr")

export CONFIG_ROOT
export HYPRMCSR_PROFILE
export REPOSITORIES_FILE
export PROFILE_CONFIG_FILE
export STATE_DIR
export HYPRMCSR
