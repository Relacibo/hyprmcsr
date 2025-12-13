#!/bin/bash

export SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")

# General profile logic
# Removed: argument parsing for PROFILE and HYPRMCSR_PROFILE
# The environment variables are used directly as they are set

export HYPRMCSR_PROFILE="${HYPRMCSR_PROFILE:-default}"
export PROFILE="${PROFILE:-default}"

# Copy example configs if not present
CONFIG_ROOT="${XDG_CONFIG_HOME:-$HOME/.config}/hyprmcsr"
PROFILE_CONFIG_FILE="$CONFIG_ROOT/default.profile.json"
EXAMPLE_PROFILE="$SCRIPT_DIR/../example.default.profile.json"

mkdir -p "$CONFIG_ROOT"
if [ ! -f "$PROFILE_CONFIG_FILE" ]; then
  cp "$EXAMPLE_PROFILE" "$PROFILE_CONFIG_FILE"
  echo "Copied example.default.profile.json to $PROFILE_CONFIG_FILE."
fi

# Source env scripts from util
source "$SCRIPT_DIR/../util/env_core.sh"
source "$SCRIPT_DIR/../util/env_prism.sh"

# Export all relevant environment variables for child processes
SCRIPT_DIR="${SCRIPT_DIR:-$(dirname "$0")}"
source "$SCRIPT_DIR/../util/export_env.sh"

if ! command -v jq >/dev/null; then
  echo "jq is required!"
  exit 1
fi

# Check for inotifywait if observeState is enabled
# Support deprecated observeLog for backward compatibility
if jq -e '.minecraft.observeLog' "$PROFILE_CONFIG_FILE" >/dev/null 2>&1; then
  echo "Warning: minecraft.observeLog is deprecated. Please use minecraft.observeState instead."
fi
OBSERVE_STATE=$(jq -r '.minecraft.observeState.enabled // .minecraft.observeLog.enabled // true' "$PROFILE_CONFIG_FILE")
if [ "$OBSERVE_STATE" = "true" ] && ! command -v inotifywait >/dev/null; then
  echo "inotifywait (from inotify-tools) is required when minecraft.observeState.enabled is true!"
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
    hyprctl keyword bindni $key,exec,"$HYPRMCSR -h $HYPRMCSR_PROFILE toggle_mode $mode"
done

toggle_binds_key=$(jq -r '.binds.toggleBinds' "$PROFILE_CONFIG_FILE")
if [ -n "$toggle_binds_key" ] && [ "$toggle_binds_key" != "null" ]; then
  hyprctl keyword bind $toggle_binds_key,exec,"$HYPRMCSR -h $HYPRMCSR_PROFILE toggle-binds"
fi

# Evaluate prismLauncher config (new) or prismWrapperCommand (deprecated)
# New format: minecraft.prismLauncher.{wrapperCommand: {autoInsert, innerCommand}, instanceId, instanceIdScript, autoLaunch}
WRAPPER_CMD=""
PRISM_INSTANCE_IDS=""
AUTO_REPLACE="false"
AUTOLAUNCH="false"

# Try new prismLauncher format first
AUTO_INSERT=$(jq -r '.minecraft.prismLauncher.wrapperCommand.autoInsert // false' "$PROFILE_CONFIG_FILE")
INNER_WRAPPER_CMD=$(jq -r '.minecraft.prismLauncher.wrapperCommand.innerCommand // empty' "$PROFILE_CONFIG_FILE")
AUTOLAUNCH=$(jq -r '.minecraft.prismLauncher.autoLaunch // false' "$PROFILE_CONFIG_FILE")

# Get instance ID - either static or from script
PRISM_INSTANCE_ID=$(jq -r '.minecraft.prismLauncher.instanceId // empty' "$PROFILE_CONFIG_FILE")
PRISM_INSTANCE_ID_SCRIPT=$(jq -r '.minecraft.prismLauncher.instanceIdScript // empty' "$PROFILE_CONFIG_FILE")

if [ -n "$PRISM_INSTANCE_ID_SCRIPT" ] && [ "$PRISM_INSTANCE_ID_SCRIPT" != "null" ]; then
  # Execute script to get instance ID (with environment variables available)
  export PROFILE HYPRMCSR_PROFILE SCRIPT_DIR STATE_DIR PRISM_PREFIX
  PRISM_INSTANCE_IDS=$(eval "$PRISM_INSTANCE_ID_SCRIPT")
elif [ -n "$PRISM_INSTANCE_ID" ] && [ "$PRISM_INSTANCE_ID" != "null" ]; then
  PRISM_INSTANCE_IDS="$PRISM_INSTANCE_ID"
fi

if [ "$AUTO_INSERT" = "true" ]; then
  # autoInsert is enabled - configure wrapper
  AUTO_REPLACE="true"
  if [ -n "$INNER_WRAPPER_CMD" ] && [ "$INNER_WRAPPER_CMD" != "null" ]; then
    WRAPPER_CMD="$HYPRMCSR -h $HYPRMCSR_PROFILE instance-wrapper $INNER_WRAPPER_CMD"
  else
    WRAPPER_CMD="$HYPRMCSR -h $HYPRMCSR_PROFILE instance-wrapper"
  fi
else
  # Fallback to deprecated prismWrapperCommand
  PRISM_WRAPPER_AUTO_REPLACE=$(jq -r '.minecraft.prismWrapperCommand.autoReplace // false' "$PROFILE_CONFIG_FILE")
  INNER_WRAPPER_CMD=$(jq -r '.minecraft.prismWrapperCommand.innerCommand // empty' "$PROFILE_CONFIG_FILE")
  PRISM_INSTANCE_IDS=$(jq -r '.minecraft.prismWrapperCommand.prismMinecraftInstanceIds[]?' "$PROFILE_CONFIG_FILE")
  
  if [ "$PRISM_WRAPPER_AUTO_REPLACE" = "true" ]; then
    echo "Warning: minecraft.prismWrapperCommand is deprecated. Please use minecraft.prismLauncher instead."
    AUTO_REPLACE="true"
    
    # Use only the outer command if innerCommand is empty/null
    if [ -n "$INNER_WRAPPER_CMD" ] && [ "$INNER_WRAPPER_CMD" != "null" ]; then
      WRAPPER_CMD="$HYPRMCSR -h $HYPRMCSR_PROFILE instance-wrapper $INNER_WRAPPER_CMD"
    else
      WRAPPER_CMD="$HYPRMCSR -h $HYPRMCSR_PROFILE instance-wrapper"
    fi
  fi
fi

if [ "$AUTO_REPLACE" = "true" ] && [ -n "$WRAPPER_CMD" ]; then
  # Check if PrismLauncher is already running
  if hyprctl clients -j | jq -e '.[] | select(.class == "org.prismlauncher.PrismLauncher" or (.title // "" | startswith("Prism Launcher")))' >/dev/null 2>&1; then
    echo "Warning: PrismLauncher is already running. Auto-replace of wrapper command will not work reliably while PrismLauncher is open."
    echo "Please close PrismLauncher and restart the profile to ensure the wrapper command is applied correctly."
  fi

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

# Create custom binds from profile config (with all relevant environment variables)
custom_binds=$(jq -r '.binds.custom // {} | to_entries[] | "\(.key) \(.value|@json)"' "$PROFILE_CONFIG_FILE")
if [ -n "$custom_binds" ]; then
  while IFS= read -r entry; do
    bind=$(echo "$entry" | awk '{print $1}')
    cmds=$(echo "$entry" | cut -d' ' -f2-)
    hyprctl keyword bind "$bind,exec,HYPRMCSR_PROFILE=\"$HYPRMCSR_PROFILE\" $SCRIPT_DIR/../util/custom_bind_wrapper.sh '$cmds'"
  done <<< "$custom_binds"
fi

# Run onStart commands from profile config (all in background, with all relevant environment variables)
on_start_cmds=$(jq -c '.onStart[]?' "$PROFILE_CONFIG_FILE")
if [ -n "$on_start_cmds" ]; then
  while IFS= read -r cmd; do
    "$SCRIPT_DIR/../util/run_conditional_command.sh" "$cmd"
  done <<< "$on_start_cmds"
fi

# Autolaunch Minecraft if enabled
if [ "$AUTOLAUNCH" = "true" ] && [ -n "$PRISM_INSTANCE_IDS" ]; then
  LAUNCH_INSTANCE_ID=$(echo "$PRISM_INSTANCE_IDS" | head -n1)
  if [ -n "$LAUNCH_INSTANCE_ID" ]; then
    echo "Autolaunching Minecraft instance: $LAUNCH_INSTANCE_ID"
    prismlauncher -l "$LAUNCH_INSTANCE_ID" &
  fi
fi

# Support deprecated observeLog for backward compatibility
OBSERVE_STATE=$(jq -r '.minecraft.observeState.enabled // .minecraft.observeLog.enabled // true' "$PROFILE_CONFIG_FILE")
if [ "$OBSERVE_STATE" = "true" ]; then
  (
    export HYPRMCSR_PROFILE PRISM_INSTANCE_ID MINECRAFT_ROOT
    setsid "$SCRIPT_DIR/observe_state.sh" >/dev/null 2>&1 &
    STATE_MONITOR_PID=$!
    echo "$STATE_MONITOR_PID" > "$STATE_DIR/observe_state.pid"
  )
fi

# Sudo handling depending on requireSudo
# (leave only the refresh/trap logic here)
auto_destroy=$(jq -r '.autoDestroyOnExit // true' "$PROFILE_CONFIG_FILE")

if [ "$REQUIRE_SUDO" = "true" ]; then
  if [ "$auto_destroy" = "true" ]; then
    while true; do sudo -v; sleep 60; done &
    SUDO_REFRESH_PID=$!
    trap 'kill $SUDO_REFRESH_PID 2>/dev/null; sudo -v; $SCRIPT_DIR/destroy.sh; exit' SIGINT SIGTERM
    echo "Press Ctrl+C to exit. On exit, destroy.sh will be executed automatically."
    sleep infinity
  fi
else
  if [ "$auto_destroy" = "true" ]; then
    trap '$SCRIPT_DIR/destroy.sh; exit' SIGINT SIGTERM
    echo "Press Ctrl+C to exit. On exit, destroy.sh will be executed automatically."
    sleep infinity
  fi
fi
