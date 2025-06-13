#!/bin/bash
set -e

source "$(dirname "$(realpath "$0")")/env_setup.sh"

# PrismLauncher path from config
PRISM_PREFIX=$(jq -r '.minecraft.prismPrefixOverride // "~/.local/share/PrismLauncher"' "$CONFIG_FILE")
PRISM_PREFIX="${PRISM_PREFIX/#\~/$HOME}"
PRISM_INSTANCE_ID=$(jq -r '.minecraft.prismInstanceId' "$CONFIG_FILE")
SAVES_DIR="$PRISM_PREFIX/instances/$PRISM_INSTANCE_ID/.minecraft/saves"

# Argument check
if [ $# -lt 2 ]; then
  echo "Usage: $0 <regex> <keep_n>"
  exit 1
fi

REGEX="$1"
KEEP_N="$2"

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
