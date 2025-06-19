#!/bin/bash

SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")
CONFIG_ROOT="${XDG_CONFIG_HOME:-$HOME/.config}/hyprmcsr"
CONFIG_FILE="$CONFIG_ROOT/config.json"

# Download root, read from global config if present, else default
DOWNLOAD_ROOT=$(jq -r '.download.root // empty' "$CONFIG_FILE")
if [ -z "$DOWNLOAD_ROOT" ] || [ "$DOWNLOAD_ROOT" = "null" ]; then
  DOWNLOAD_ROOT=$(realpath "$SCRIPT_DIR/../download")
fi
JARS_DIR="$DOWNLOAD_ROOT/jar"

if [ $# -lt 1 ]; then
  echo "Usage: $0 <prefix> [args...]"
  exit 1
fi

PREFIX="$1"
shift

# If a full filename with .jar is given and exists, use it directly
if [[ "$PREFIX" == *.jar ]] && [ -f "$JARS_DIR/$PREFIX" ]; then
  JAR_FILE="$JARS_DIR/$PREFIX"
else
  # Search for the first matching JAR with prefix
  JAR_FILE=$(find "$JARS_DIR" -maxdepth 1 -type f -name "${PREFIX}*.jar" | head -n1)
fi

if [ -z "$JAR_FILE" ]; then
  echo "No JAR file found with prefix '$PREFIX' in $JARS_DIR"
  exit 2
fi

# Determine working directory
WORKDIR="${JAR_WORKDIR:-/tmp/hyprmcsr-jar}"
mkdir -p "$WORKDIR"
cd "$WORKDIR"

java -jar "$JAR_FILE" "$@"
