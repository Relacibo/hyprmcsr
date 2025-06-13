#!/bin/bash

SCRIPT_DIR=$(dirname "$(realpath "$0")")
CONFIG_ROOT="${XDG_CONFIG_HOME:-$HOME/.config}/hyprmcsr"
GLOBAL_CONFIG_FILE="$CONFIG_ROOT/config.json"

# Download-Root ggf. aus globaler Config lesen, sonst Default
DOWNLOAD_ROOT=$(jq -r '.download.root // empty' "$GLOBAL_CONFIG_FILE")
if [ -z "$DOWNLOAD_ROOT" ] || [ "$DOWNLOAD_ROOT" = "null" ]; then
  DOWNLOAD_ROOT="$SCRIPT_DIR/../download"
fi
JARS_DIR="$DOWNLOAD_ROOT/jars"

if [ $# -lt 1 ]; then
  echo "Usage: $0 <prefix> [args...]"
  exit 1
fi

PREFIX="$1"
shift

# Suche nach der ersten passenden JAR-Datei mit dem Präfix
JAR_FILE=$(find "$JARS_DIR" -maxdepth 1 -type f -name "${PREFIX}*.jar" | head -n1)

if [ -z "$JAR_FILE" ]; then
  echo "No JAR file found with prefix '$PREFIX' in $JARS_DIR"
  exit 2
fi

# Arbeitsverzeichnis bestimmen
WORKDIR="${JAR_WORKDIR:-/tmp/hyprmcsr-jar}"
mkdir -p "$WORKDIR"
cd "$WORKDIR"

java -jar "$JAR_FILE" "$@"
