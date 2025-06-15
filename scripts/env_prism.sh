#!/bin/bash
source "$(dirname "$(realpath "$0")")/env_core.sh"

PRISM_PREFIX=$(jq -r '.minecraft.prismPrefixOverride // "~/.local/share/PrismLauncher"' "$CONFIG_FILE")
PRISM_PREFIX="${PRISM_PREFIX/#\~/$HOME}"
export PRISM_PREFIX

PRISM_INSTANCE_ID=$(jq -r '.minecraft.prismInstanceId' "$CONFIG_FILE")
export PRISM_INSTANCE_ID

PRISM_INSTANCE_CONFIG="$PRISM_PREFIX/instances/$PRISM_INSTANCE_ID/instance.cfg"
export PRISM_INSTANCE_CONFIG

# Check for explicit override for Minecraft root folder
MINECRAFT_ROOT=$(jq -r '.minecraft.minecraftRootFolderOverride // empty' "$CONFIG_FILE")
if [ -n "$MINECRAFT_ROOT" ] && [ "$MINECRAFT_ROOT" != "null" ]; then
  # If relative path, resolve relative to $PRISM_PREFIX/instances/$PRISM_INSTANCE_ID
  case "$MINECRAFT_ROOT" in
    /*) ;; # absolute, do nothing
    ~*) MINECRAFT_ROOT="${MINECRAFT_ROOT/#\~/$HOME}" ;; # replace ~
    *) MINECRAFT_ROOT="$PRISM_PREFIX/instances/$PRISM_INSTANCE_ID/$MINECRAFT_ROOT" ;;
  esac
else
  MINECRAFT_ROOT=$(grep '^OverrideMinecraftDir=' "$PRISM_INSTANCE_CONFIG" 2>/dev/null | cut -d= -f2-)
  if [ -z "$MINECRAFT_ROOT" ]; then
    MINECRAFT_ROOT="$PRISM_PREFIX/instances/$PRISM_INSTANCE_ID/minecraft"
  fi
fi
export MINECRAFT_ROOT
