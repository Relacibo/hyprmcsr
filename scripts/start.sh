#!/bin/bash
# filepath: /home/reinhard/git/hyprmcsr/scripts/start.sh

SCRIPT_DIR="$(dirname "$(realpath "$0")")"

# General profile logic
# Entfernt: Argumenten-Parsing für PROFILE und HYPRMCSR_PROFILE
# Die Umgebungsvariablen werden direkt verwendet, wie sie gesetzt sind

export HYPRMCSR_PROFILE="${HYPRMCSR_PROFILE:-default}"
source "$SCRIPT_DIR/env_core.sh"
source "$SCRIPT_DIR/env_prism.sh"

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
    hyprctl keyword bindni $key,exec,"HYPRMCSR_PROFILE=\"$HYPRMCSR_PROFILE\" $SCRIPT_DIR/toggle_mode.sh $mode"
done

toggle_binds_key=$(jq -r '.binds.toggleBinds' "$PROFILE_CONFIG_FILE")
if [ -n "$toggle_binds_key" ] && [ "$toggle_binds_key" != "null" ]; then
  hyprctl keyword bind $toggle_binds_key,exec,"HYPRMCSR_PROFILE=\"$HYPRMCSR_PROFILE\" $SCRIPT_DIR/toggle_binds.sh"
fi

# Evaluate prismWrapperCommand
PRISM_WRAPPER_AUTO_REPLACE=$(jq -r '.minecraft.prismWrapperCommand.autoReplace // true' "$PROFILE_CONFIG_FILE")
INNER_WRAPPER_CMD=$(jq -r '.minecraft.prismWrapperCommand.innerCommand // empty' "$PROFILE_CONFIG_FILE")

if [ "$PRISM_WRAPPER_AUTO_REPLACE" = "true" ]; then
  if [ -n "$INNER_WRAPPER_CMD" ] && [ "$INNER_WRAPPER_CMD" != "null" ] && [ "$INNER_WRAPPER_CMD" != "empty" ]; then
    if [ -f "$PRISM_INSTANCE_CONFIG" ]; then
      # Schreibe den innerCommand direkt in den WrapperCommand
      WRAPPER_CMD="$SCRIPT_DIR/../bin/hyprmcsr -h $HYPRMCSR_PROFILE instance-wrapper $INNER_WRAPPER_CMD"
      if grep -q "^WrapperCommand=" "$PRISM_INSTANCE_CONFIG"; then
        sed -i "s|^WrapperCommand=.*|WrapperCommand=$WRAPPER_CMD|" "$PRISM_INSTANCE_CONFIG"
      else
        echo "WrapperCommand=$WRAPPER_CMD" >> "$PRISM_INSTANCE_CONFIG"
      fi
      # Enable custom commands
      if grep -q "^UseCustomCommands=" "$PRISM_INSTANCE_CONFIG"; then
        sed -i "s|^UseCustomCommands=.*|UseCustomCommands=true|" "$PRISM_INSTANCE_CONFIG"
      else
        echo "UseCustomCommands=true" >> "$PRISM_INSTANCE_CONFIG"
      fi
    fi
  fi
fi

# Minecraft autostart (can be disabled in profile config)
MC_AUTOSTART=$(jq -r '.minecraft.autoStart // true' "$PROFILE_CONFIG_FILE")
if [ "$MC_AUTOSTART" = "true" ]; then
  prismlauncher -l "$PRISM_INSTANCE_ID" &
fi

# Create custom binds from config.json (with all relevant environment variables)
custom_binds=$(jq -r '.binds.custom // {} | to_entries[] | "\(.key) \(.value|@json)"' "$PROFILE_CONFIG_FILE")
if [ -n "$custom_binds" ]; then
  while IFS= read -r entry; do
    bind=$(echo "$entry" | awk '{print $1}')
    cmds=$(echo "$entry" | cut -d' ' -f2-)
    hyprctl keyword bind "$bind,exec,HYPRMCSR_PROFILE=\"$HYPRMCSR_PROFILE\" PRISM_INSTANCE_ID=\"$PRISM_INSTANCE_ID\" MINECRAFT_ROOT=\"$MINECRAFT_ROOT\" $SCRIPT_DIR/custom_bind_wrapper.sh '$cmds'"
  done <<< "$custom_binds"
fi

# Run onStart commands from config.json (all in background, with all relevant environment variables)
on_start_cmds=$(jq -r '.onStart[]?' "$PROFILE_CONFIG_FILE")
if [ -n "$on_start_cmds" ]; then
  (
    export SCRIPT_DIR PROFILE HYPRMCSR_PROFILE PRISM_INSTANCE_ID MINECRAFT_ROOT WINDOW_ADDRESS
    while IFS= read -r cmd; do
      bash -c "$cmd" &
    done <<< "$on_start_cmds"
  )
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
