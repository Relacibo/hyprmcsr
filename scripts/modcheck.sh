#!/bin/bash
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
JAR_PATH="$SCRIPT_DIR/../jars"
FILE_PATH=$(find "$JAR_PATH" -type f -name "modcheck-*.jar" | head -n1)

"$SCRIPT_DIR/runjar.sh" "$FILE_PATH" &
