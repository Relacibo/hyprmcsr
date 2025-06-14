#!/bin/bash
sudo -v

SCRIPT_DIR="$(dirname "$(realpath "$0")")"

# Allgemeine Profil-Logik
if [[ "$1" == --* ]]; then
  export PROFILE="${1#--}"
  shift
else
  export PROFILE=""
fi

export HYPRMCSR_PROFILE="${1:-default}"
source "$SCRIPT_DIR/env_core.sh"
source "$SCRIPT_DIR/env_prism.sh"

if ! command -v jq >/dev/null; then
  echo "jq wird benötigt!"
  exit 1
fi

echo "default" > "$STATE_DIR/window_switcher_state"
echo "$HYPRMCSR_PROFILE" > "$STATE_DIR/profile"

jq -r '.binds.modeSwitch | to_entries[] | "\(.key) \(.value)"' "$CONFIG_FILE" | while read -r mode key; do
    hyprctl keyword bindni $key,exec,"HYPRMCSR_PROFILE=\"$HYPRMCSR_PROFILE\" $SCRIPT_DIR/toggle_mode.sh $mode"
done

toggle_binds_key=$(jq -r '.binds.toggleBinds' "$CONFIG_FILE")
if [ -n "$toggle_binds_key" ] && [ "$toggle_binds_key" != "null" ]; then
  hyprctl keyword bind $toggle_binds_key,exec,"HYPRMCSR_PROFILE=\"$HYPRMCSR_PROFILE\" $SCRIPT_DIR/toggle_binds.sh"
fi

# prismReplaceWrapperCommand auswerten
PRISM_REPLACE_WRAPPER_ENABLED=$(jq -r '.minecraft.prismReplaceWrapperCommand.enabled // true' "$CONFIG_FILE")
INNER_WRAPPER_CMD=$(jq -r '.minecraft.prismReplaceWrapperCommand.innerWrapperCommand // empty' "$CONFIG_FILE")

if [ "$PRISM_REPLACE_WRAPPER_ENABLED" = "true" ]; then
  if [ -n "$INNER_WRAPPER_CMD" ] && [ "$INNER_WRAPPER_CMD" != "null" ]; then
    if [ -f "$PRISM_INSTANCE_CONFIG" ]; then
      WRAPPER_CMD="$SCRIPT_DIR/../bin/hyprmcsr -h $HYPRMCSR_PROFILE instance-wrapper"
      if grep -q "^WrapperCommand=" "$PRISM_INSTANCE_CONFIG"; then
        sed -i "s|^WrapperCommand=.*|WrapperCommand=$WRAPPER_CMD|" "$PRISM_INSTANCE_CONFIG"
      else
        echo "WrapperCommand=$WRAPPER_CMD" >> "$PRISM_INSTANCE_CONFIG"
      fi
      # Benutzerdefinierte Befehle aktivieren
      if grep -q "^UseCustomCommands=" "$PRISM_INSTANCE_CONFIG"; then
        sed -i "s|^UseCustomCommands=.*|UseCustomCommands=true|" "$PRISM_INSTANCE_CONFIG"
      else
        echo "UseCustomCommands=true" >> "$PRISM_INSTANCE_CONFIG"
      fi
    fi
  fi
fi

# Minecraft autostart (can be disabled in profile config)
MC_AUTOSTART=$(jq -r '.minecraft.autoStart // true' "$CONFIG_FILE")
if [ "$MC_AUTOSTART" = "true" ]; then
  prismlauncher -l "$PRISM_INSTANCE_ID" &
fi

# Custom binds aus config.json anlegen (mit allen relevanten Umgebungsvariablen)
custom_binds=$(jq -r '.binds.custom | to_entries[] | "\(.key) \(.value|@json)"' "$CONFIG_FILE")
if [ -n "$custom_binds" ]; then
  while IFS= read -r entry; do
    bind=$(echo "$entry" | awk '{print $1}')
    cmds=$(echo "$entry" | cut -d' ' -f2-)
    hyprctl keyword bind "$bind,exec,HYPRMCSR_PROFILE=\"$HYPRMCSR_PROFILE\" PRISM_INSTANCE_ID=\"$PRISM_INSTANCE_ID\" MINECRAFT_ROOT=\"$MINECRAFT_ROOT\" $SCRIPT_DIR/custom_bind_wrapper.sh '$cmds'"
  done <<< "$custom_binds"
fi

# Input Remapper für Devices (vereinheitlicht)
jq -c '.inputRemapper.devices[]' "$CONFIG_FILE" | while read -r device_entry; do
  device=$(echo "$device_entry" | jq -r '.device')
  preset=$(echo "$device_entry" | jq -r '.preset')
  sudo input-remapper-control --command start --device "$device" --preset "$preset"
done

# Run onStart commands from config.json (alle im Hintergrund, mit allen relevanten Umgebungsvariablen)
on_start_cmds=$(jq -r '.onStart[]?' "$CONFIG_FILE")
if [ -n "$on_start_cmds" ]; then
  (
    export SCRIPT_DIR PROFILE HYPRMCSR_PROFILE PRISM_INSTANCE_ID MINECRAFT_ROOT WINDOW_ADDRESS
    while IFS= read -r cmd; do
      bash -c "$cmd" &
    done <<< "$on_start_cmds"
  )
fi

OBSERVE_LOG=$(jq -r '.minecraft.observeLog.enabled // true' "$CONFIG_FILE")
if [ "$OBSERVE_LOG" = "true" ]; then
  (
    export HYPRMCSR_PROFILE PRISM_INSTANCE_ID MINECRAFT_ROOT
    $SCRIPT_DIR/observe_log.sh &
    LOG_MONITOR_PID=$!
  )
fi

# Option aus config lesen (default: true)
auto_destroy=$(jq -r '.autoDestroyOnExit // true' "$CONFIG_FILE")

if [ "$auto_destroy" = "true" ]; then
  # Sudo-Ticket regelmäßig erneuern, solange das Skript läuft
  while true; do sudo -v; sleep 60; done &
  SUDO_REFRESH_PID=$!
  # Trap für SIGINT und SIGTERM setzen
  trap 'kill $SUDO_REFRESH_PID 2>/dev/null; kill $LOG_MONITOR_PID 2>/dev/null; sudo -v; $SCRIPT_DIR/destroy.sh; exit' SIGINT SIGTERM
  echo "Drücke Strg+C zum Beenden. Beim Beenden wird destroy.sh automatisch ausgeführt."
  sleep infinity
fi
