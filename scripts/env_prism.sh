#!/bin/bash
source "$(dirname "$(realpath "$0")")/env_core.sh"

PRISM_PREFIX=$(jq -r '.minecraft.prismPrefixOverride // "~/.local/share/PrismLauncher"' "$CONFIG_FILE")
PRISM_PREFIX="${PRISM_PREFIX/#\~/$HOME}"
export PRISM_PREFIX

PRISM_INSTANCE_ID=$(jq -r '.minecraft.prismInstanceId' "$CONFIG_FILE")
export PRISM_INSTANCE_ID

PRISM_INSTANCE_CONFIG="$PRISM_PREFIX/instances/$PRISM_INSTANCE_ID/instance.cfg"
export PRISM_INSTANCE_CONFIG

# Prüfe auf expliziten Override für den Minecraft-Root-Ordner
MINECRAFT_ROOT=$(jq -r '.minecraft.minecraftRootFolderOverride // empty' "$CONFIG_FILE")
if [ -n "$MINECRAFT_ROOT" ] && [ "$MINECRAFT_ROOT" != "null" ]; then
  # Wenn relativer Pfad, dann relativ zu $PRISM_PREFIX/instances/$PRISM_INSTANCE_ID auflösen
  case "$MINECRAFT_ROOT" in
    /*) ;; # absolut, nichts tun
    ~*) MINECRAFT_ROOT="${MINECRAFT_ROOT/#\~/$HOME}" ;; # ~ ersetzen
    *) MINECRAFT_ROOT="$PRISM_PREFIX/instances/$PRISM_INSTANCE_ID/$MINECRAFT_ROOT" ;;
  esac
else
  MINECRAFT_ROOT=$(grep '^OverrideMinecraftDir=' "$PRISM_INSTANCE_CONFIG" 2>/dev/null | cut -d= -f2-)
  if [ -z "$MINECRAFT_ROOT" ]; then
    MINECRAFT_ROOT="$PRISM_PREFIX/instances/$PRISM_INSTANCE_ID/.minecraft"
  fi
fi
export MINECRAFT_ROOT
