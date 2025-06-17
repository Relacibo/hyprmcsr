#!/bin/bash
source "$(dirname "$(realpath "$0")")/env_core.sh"

PRISM_PREFIX=$(jq -r '.minecraft.prismPrefixOverride // "~/.local/share/PrismLauncher"' "$PROFILE_CONFIG_FILE")
PRISM_PREFIX="${PRISM_PREFIX/#\~/$HOME}"
export PRISM_PREFIX

# Prefer environment/state files set by PrismLauncher/instance_wrapper
if [ -f "$STATE_DIR/prism_instance_id" ]; then
  PRISM_INSTANCE_ID=$(cat "$STATE_DIR/prism_instance_id")
else
  PRISM_INSTANCE_ID=$(jq -r '.minecraft.prismInstanceId' "$PROFILE_CONFIG_FILE")
fi
export PRISM_INSTANCE_ID

PRISM_INSTANCE_CONFIG="$PRISM_PREFIX/instances/$PRISM_INSTANCE_ID/instance.cfg"
export PRISM_INSTANCE_CONFIG

if [ -f "$STATE_DIR/minecraft_root" ]; then
  MINECRAFT_ROOT=$(cat "$STATE_DIR/minecraft_root")
else
  # Fallback: use default PrismLauncher instance path
  MINECRAFT_ROOT="$PRISM_PREFIX/instances/$PRISM_INSTANCE_ID/minecraft"
fi
export MINECRAFT_ROOT
