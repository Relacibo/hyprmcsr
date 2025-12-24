#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/env_core.sh"

# Determine PRISM_PREFIX with priority: prismLauncher.prismPrefix > flatpak detection > deprecated prismPrefix > default
PRISM_PREFIX=$(jq -r '.minecraft.prismLauncher.prismPrefix // empty' "$PROFILE_CONFIG_FILE")

if [ -z "$PRISM_PREFIX" ] || [ "$PRISM_PREFIX" = "null" ]; then
  # Check if flatpak installation is configured
  IS_FLATPAK=$(jq -r '.minecraft.prismLauncher.flatpak // false' "$PROFILE_CONFIG_FILE")
  if [ "$IS_FLATPAK" = "true" ]; then
    PRISM_PREFIX="$HOME/.var/app/org.prismlauncher.PrismLauncher/data/PrismLauncher"
  else
    # Fallback to deprecated prismPrefix, then default
    PRISM_PREFIX=$(jq -r '.minecraft.prismPrefix // "~/.local/share/PrismLauncher"' "$PROFILE_CONFIG_FILE")
  fi
fi

PRISM_PREFIX="${PRISM_PREFIX/#\~/$HOME}"
export PRISM_PREFIX

# Prefer environment/state files set by PrismLauncher/instance_wrapper
if [ -f "$STATE_DIR/prism_instance_id" ]; then
  PRISM_INSTANCE_ID=$(cat "$STATE_DIR/prism_instance_id")
fi
export PRISM_INSTANCE_ID

PRISM_INSTANCE_CONFIG="$PRISM_PREFIX/instances/$PRISM_INSTANCE_ID/instance.cfg"
export PRISM_INSTANCE_CONFIG

if [ -f "$STATE_DIR/minecraft_root" ]; then
  MINECRAFT_ROOT=$(cat "$STATE_DIR/minecraft_root")
elif [ -n "$PRISM_INSTANCE_ID" ]; then
  # Fallback: use default PrismLauncher instance path only if PRISM_INSTANCE_ID is set
  MINECRAFT_ROOT="$PRISM_PREFIX/instances/$PRISM_INSTANCE_ID/minecraft"
fi
export MINECRAFT_ROOT
