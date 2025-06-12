#!/bin/bash
sudo bash -c :

SCRIPT_DIR=$(dirname $(realpath "$0"))
CONFIG_FILE="$SCRIPT_DIR/../config.json"
WINDOW_ADDRESS_FILE="$SCRIPT_DIR/../var/window_address"

if ! command -v jq >/dev/null; then
  echo "jq wird benötigt!"
  exit 1
fi

if [ "$1" = "--coop" ]; then
  PROFILE="coop"
else
  PROFILE="${1:-default}"
fi
export PROFILE

echo "default" > "$SCRIPT_DIR/../var/window_switcher_state"

jq -r '.binds.modeSwitch | to_entries[] | "\(.key) \(.value)"' "$CONFIG_FILE" | while read -r mode key; do
    hyprctl keyword bindni $key,exec,"$SCRIPT_DIR/toggle_mode.sh $mode"
done

toggle_binds_key=$(jq -r '.binds.toggleBinds' "$CONFIG_FILE")
if [ -n "$toggle_binds_key" ] && [ "$toggle_binds_key" != "null" ]; then
  hyprctl keyword bind $toggle_binds_key,exec,"$SCRIPT_DIR/toggle_binds.sh"
fi
PROFILE="${1:-default}"
export PROFILE
echo "$PROFILE" > "$SCRIPT_DIR/../var/profile"

# Run onStart commands from config.json (all in background)
on_start_cmds=$(jq -r '.onStart[]?' "$CONFIG_FILE")
if [ -n "$on_start_cmds" ]; then
  while IFS= read -r cmd; do
    SCRIPT_DIR="$SCRIPT_DIR" PROFILE="$PROFILE" bash -c "$cmd" &
  done <<< "$on_start_cmds"
fi

# Input Remapper für Devices (vereinheitlicht)
jq -c '.inputRemapper.devices[]' "$CONFIG_FILE" | while read -r device_entry; do
  device=$(echo "$device_entry" | jq -r '.device')
  preset=$(echo "$device_entry" | jq -r '.preset')
  sudo input-remapper-control --command start --device "$device" --preset "$preset"
done

mkdir -p $SCRIPT_DIR/../var

$SCRIPT_DIR/minecraft.sh

OBSERVE_LOG=$(jq -r '.minecraft.observeLog.enabled // 1' "$CONFIG_FILE")
if [ "$OBSERVE_LOG" = "true" ]; then
  $SCRIPT_DIR/observe_log.sh &
  LOG_MONITOR_PID=$!
fi

# Option aus config lesen (default: true)
auto_destroy=$(jq -r '.autoDestroyOnExit // true' "$CONFIG_FILE")

if [ "$auto_destroy" = "true" ]; then
  # Trap für SIGINT und SIGTERM setzen
  trap 'kill $LOG_MONITOR_PID 2>/dev/null; $SCRIPT_DIR/destroy.sh; exit' SIGINT SIGTERM
  echo "Drücke Strg+C zum Beenden. Beim Beenden wird destroy.sh automatisch ausgeführt."
  sleep infinity
fi
