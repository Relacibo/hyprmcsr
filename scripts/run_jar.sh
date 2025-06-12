#!/bin/bash

SCRIPT_DIR=$(dirname "$(realpath "$0")")
JARS_DIR="$SCRIPT_DIR/../jars"

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

cd "$SCRIPT_DIR/.."
java -jar "$JAR_FILE" "$@"
