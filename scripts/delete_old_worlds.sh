#!/bin/bash
set -e

SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")
source "$SCRIPT_DIR/env_prism.sh"

SAVES_DIR="$MINECRAFT_ROOT/saves"

# Argument check
if [ $# -ne 2 ]; then
  echo "Usage: $0 <regex> <keep_n>"
  exit 1
fi

REGEX="$1"
KEEP_N="$2"

# Check if KEEP_N is a number
if ! [[ "$KEEP_N" =~ ^[0-9]+$ ]]; then
  echo "Error: <keep_n> must be a number."
  exit 1
fi

if [ ! -d "$SAVES_DIR" ]; then
  echo "Saves directory not found: $SAVES_DIR"
  exit 2
fi

# List worlds, filter by regex (handle spaces)
mapfile -t worlds < <(
  find "$SAVES_DIR" -mindepth 1 -maxdepth 1 -type d -printf "%T@ %f\n" | sort -n | cut -d' ' -f2- | grep -E "$REGEX"
)

total=${#worlds[@]}

if [ "$total" -le "$KEEP_N" ]; then
  echo "Nothing to delete. Only $total worlds found matching '$REGEX'."
  exit 0
fi

to_delete=("${worlds[@]:0:$(($total - $KEEP_N))}")

count=${#to_delete[@]}
if [ "$count" -eq 0 ]; then
  echo "Nothing to delete. Only $total worlds found matching '$REGEX'."
  exit 0
fi

for w in "${to_delete[@]}"; do
  rm -rf "$SAVES_DIR/$w"
done

echo "Deleted $count worlds matching '$REGEX'. Kept the $KEEP_N newest."
