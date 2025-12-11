#!/bin/bash

export SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")
CONFIG_ROOT="${XDG_CONFIG_HOME:-$HOME/.config}/hyprmcsr"
REPOSITORIES_FILE="$CONFIG_ROOT/repositories.json"
PROFILE_CONFIG_FILE="$CONFIG_ROOT/default.profile.json"
EXAMPLE_REPOSITORIES="$SCRIPT_DIR/../example.repositories.json"
EXAMPLE_PROFILE="$SCRIPT_DIR/../example.default.profile.json"

mkdir -p "$CONFIG_ROOT"

# Copy repositories.json if not exists
if [ ! -f "$REPOSITORIES_FILE" ]; then
  cp "$EXAMPLE_REPOSITORIES" "$REPOSITORIES_FILE"
  echo "Created $REPOSITORIES_FILE"
else
  echo "File already exists: $REPOSITORIES_FILE"
fi

# Copy default.profile.json if not exists
if [ ! -f "$PROFILE_CONFIG_FILE" ]; then
  cp "$EXAMPLE_PROFILE" "$PROFILE_CONFIG_FILE"
  echo "Created $PROFILE_CONFIG_FILE"
else
  echo "File already exists: $PROFILE_CONFIG_FILE"
fi

echo "Initialization complete. Configuration files are in $CONFIG_ROOT"
