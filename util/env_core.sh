#!/bin/bash

CONFIG_ROOT="${XDG_CONFIG_HOME:-$HOME/.config}/hyprmcsr"
mkdir -p "$CONFIG_ROOT"

HYPRMCSR_PROFILE="${HYPRMCSR_PROFILE:-default}"

# Profile names end up in file paths: never allow path separators or dot names.
if [[ ! "$HYPRMCSR_PROFILE" =~ ^[A-Za-z0-9._-]+$ || "$HYPRMCSR_PROFILE" == "." || "$HYPRMCSR_PROFILE" == ".." ]]; then
    echo "Invalid profile name '$HYPRMCSR_PROFILE'. Use only letters, digits, '.', '_' and '-'." >&2
    exit 1
fi

PROFILE_CONFIG_FILE="$CONFIG_ROOT/${HYPRMCSR_PROFILE}.profile.json"
REPOSITORIES_FILE="$CONFIG_ROOT/repositories.json"

# Read STATE_DIR from profile config if present (requires jq and profile file)
STATE_DIR=$(jq -r '.stateDir // empty' "$PROFILE_CONFIG_FILE" 2>/dev/null)

if [ -z "$STATE_DIR" ]; then
    BASE_DIR="${XDG_RUNTIME_DIR:-/run/user/$UID}"
    
    if [ -d "$BASE_DIR" ] && [ -w "$BASE_DIR" ]; then
        STATE_DIR="$BASE_DIR/hyprmcsr/profile/$HYPRMCSR_PROFILE"
    else
        STATE_DIR="/tmp/hyprmcsr-$UID/profile/$HYPRMCSR_PROFILE"
    fi
fi

mkdir -p "$STATE_DIR"
chmod 700 "$STATE_DIR" 2>/dev/null || true

# Callers normally set SCRIPT_DIR, but fall back to this file's location.
SCRIPT_DIR="${SCRIPT_DIR:-$(realpath "$(dirname "${BASH_SOURCE[0]}")/../scripts")}"
HYPRMCSR=$(realpath "$SCRIPT_DIR/../bin/hyprmcsr")

export CONFIG_ROOT
export HYPRMCSR_PROFILE
export REPOSITORIES_FILE
export PROFILE_CONFIG_FILE
export STATE_DIR
export HYPRMCSR
