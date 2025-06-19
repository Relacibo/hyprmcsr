#!/bin/bash

SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")

# General profile logic
# Entfernt: Argumenten-Parsing für PROFILE und HYPRMCSR_PROFILE
# Die Umgebungsvariablen werden direkt verwendet, wie sie gesetzt sind

export HYPRMCSR_PROFILE="${HYPRMCSR_PROFILE:-default}"
export PROFILE="${PROFILE:-default}"
# Source env scripts from util
source "$SCRIPT_DIR/../util/env_core.sh"
source "$SCRIPT_DIR/../util/env_prism.sh"

if ! command -v jq >/dev/null; then
  echo "jq is required!"
  exit 1
fi

# Check for sudo requirement early
REQUIRE_SUDO=$(jq -r '.requireSudo // false' "$PROFILE_CONFIG_FILE")
if [ "$REQUIRE_SUDO" = "true" ]; then
  sudo -v
fi

echo "default" > "$STATE_DIR/window_switcher_state"
echo "$HYPRMCSR_PROFILE" > "$STATE_DIR/profile"

# Set keybinds for mode switches
jq -r '.binds.modeSwitch | to_entries[] | "\(.key) \(.value)"' "$PROFILE_CONFIG_FILE" | while read -r mode key; do
    hyprctl keyword bindni $key,exec,"$HYPRMCSR_BIN -h $HYPRMCSR_PROFILE toggle_mode $mode"
done

toggle_binds_key=$(jq -r '.binds.toggleBinds' "$PROFILE_CONFIG_FILE")
if [ -n "$toggle_binds_key" ] && [ "$toggle_binds_key" != "null" ]; then
  hyprctl keyword bind $toggle_binds_key,exec,"$HYPRMCSR_BIN -h $HYPRMCSR_PROFILE toggle_binds"
fi

# Evaluate prismWrapperCommand
PRISM_WRAPPER_AUTO_REPLACE=$(jq -r '.minecraft.prismWrapperCommand.autoReplace // true' "$PROFILE_CONFIG_FILE")
INNER_WRAPPER_CMD=$(jq -r '.minecraft.prismWrapperCommand.innerCommand // empty' "$PROFILE_CONFIG_FILE")
PRISM_INSTANCE_IDS=$(jq -r '.minecraft.prismWrapperCommand.prismMinecraftInstanceIds[]?' "$PROFILE_CONFIG_FILE")

# Fallback: Use only the outer command if innerCommand is empty/null
if [ "$INNER_WRAPPER_CMD" = "null" ] || [ "$INNER_WRAPPER_CMD" = "empty" ] || [ -z "$INNER_WRAPPER_CMD" ]; then
  WRAPPER_CMD="$HYPRMCSR_BIN -h $HYPRMCSR_PROFILE instance-wrapper"
else
  WRAPPER_CMD="$HYPRMCSR_BIN -h $HYPRMCSR_PROFILE instance-wrapper $INNER_WRAPPER_CMD"
fi

if [ "$PRISM_WRAPPER_AUTO_REPLACE" = "true" ]; then
  if [ -n "$PRISM_INSTANCE_IDS" ]; then
    echo "$PRISM_INSTANCE_IDS" | while IFS= read -r INSTANCE_ID; do
      [ -z "$INSTANCE_ID" ] && continue
      INSTANCE_CONFIG="$PRISM_PREFIX/instances/$INSTANCE_ID/instance.cfg"
      if [ -f "$INSTANCE_CONFIG" ]; then
        # Set WrapperCommand and UseCustomCommands in [General] section only
        if grep -q "^\[General\]" "$INSTANCE_CONFIG"; then
          "$SCRIPT_DIR/../util/instance_cfg_util.sh" "$INSTANCE_CONFIG" "$WRAPPER_CMD"
        fi
      fi
    done
  fi
fi

# Create custom binds from config.json (with all relevant environment variables)
custom_binds=$(jq -r '.binds.custom // {} | to_entries[] | "\(.key) \(.value|@json)"' "$PROFILE_CONFIG_FILE")
if [ -n "$custom_binds" ]; then
  while IFS= read -r entry; do
    bind=$(echo "$entry" | awk '{print $1}')
    cmds=$(echo "$entry" | cut -d' ' -f2-)
    hyprctl keyword bind "$bind,exec,$HYPRMCSR_BIN -h $HYPRMCSR_PROFILE custom-bind-wrapper '$cmds'"
  done <<< "$custom_binds"
fi

# Run onStart commands from config.json (all in background, with all relevant environment variables)
on_start_cmds=$(jq -c '.onStart[]?' "$PROFILE_CONFIG_FILE")
if [ -n "$on_start_cmds" ]; then
  while IFS= read -r cmd; do
    "$SCRIPT_DIR/../util/run_conditional_command.sh" "$cmd"
  done <<< "$on_start_cmds"
fi

OBSERVE_LOG=$(jq -r '.minecraft.observeLog.enabled // true' "$PROFILE_CONFIG_FILE")
if [ "$OBSERVE_LOG" = "true" ]; then
  (
    export HYPRMCSR_PROFILE PRISM_INSTANCE_ID MINECRAFT_ROOT
    $SCRIPT_DIR/observe_log.sh &
    LOG_MONITOR_PID=$!
  )
fi

# Sudo handling depending on requireSudo
# (leave only the refresh/trap logic here)
auto_destroy=$(jq -r '.autoDestroyOnExit // true' "$PROFILE_CONFIG_FILE")

if [ "$REQUIRE_SUDO" = "true" ]; then
  if [ "$auto_destroy" = "true" ]; then
    while true; do sudo -v; sleep 60; done &
    SUDO_REFRESH_PID=$!
    trap 'kill $SUDO_REFRESH_PID 2>/dev/null; kill $LOG_MONITOR_PID 2>/dev/null; sudo -v; $SCRIPT_DIR/destroy.sh; exit' SIGINT SIGTERM
    echo "Press Ctrl+C to exit. On exit, destroy.sh will be executed automatically."
    sleep infinity
  fi
else
  if [ "$auto_destroy" = "true" ]; then
    trap 'kill $LOG_MONITOR_PID 2>/dev/null; $SCRIPT_DIR/destroy.sh; exit' SIGINT SIGTERM
    echo "Press Ctrl+C to exit. On exit, destroy.sh will be executed automatically."
    sleep infinity
  fi
fi
