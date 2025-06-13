#!/bin/bash
source "$(dirname "$(realpath "$0")")/env_setup.sh"

sudo input-remapper-control --command stop-all

WINDOW_ADDRESS=$(cat "$STATE_DIR/window_address" 2>/dev/null || echo "")

toggle_binds_key=$(jq -r '.binds.toggleBinds' "$CONFIG_FILE")
if [ -n "$toggle_binds_key" ] && [ "$toggle_binds_key" != "null" ]; then
  hyprctl keyword unbind $toggle_binds_key
fi

# Custom binds entfernen
custom_binds=$(jq -r '.binds.custom | to_entries[] | .key' "$CONFIG_FILE")
if [ -n "$custom_binds" ]; then
  while IFS= read -r bind; do
    hyprctl keyword unbind "$bind"
  done <<< "$custom_binds"
fi

jq -r '.binds.modeSwitch | to_entries[] | "\(.key) \(.value)"' "$CONFIG_FILE" | while read -r mode key; do
  hyprctl keyword unbind $key
done

PROFILE=$(cat "$STATE_DIR/profile" 2>/dev/null || echo "default")
PRISM_INSTANCE_ID=$(jq -r '.minecraft.prismInstanceId' "$CONFIG_FILE")
PRISM_PREFIX=$(jq -r '.minecraft.prismPrefixOverride // "~/.local/share/PrismLauncher"' "$CONFIG_FILE")
PRISM_PREFIX="${PRISM_PREFIX/#\~/$HOME}"
MINECRAFT_ROOT="$PRISM_PREFIX/instances/$PRISM_INSTANCE_ID/.minecraft"

on_destroy_cmds=$(jq -r '.onDestroy[]?' "$CONFIG_FILE")
if [ -n "$on_destroy_cmds" ]; then
  (
    export WINDOW_ADDRESS SCRIPT_DIR PROFILE HYPRMCSR_PROFILE PRISM_INSTANCE_ID MINECRAFT_ROOT
    while IFS= read -r cmd; do
      bash -c "$cmd" &
    done <<< "$on_destroy_cmds"
  )
fi

rm -rf "$STATE_DIR"
