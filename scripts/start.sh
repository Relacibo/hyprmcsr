#!/bin/bash
sudo bash -c :

source "$(dirname "$(realpath "$0")")/env_setup.sh"

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

echo "default" > "$STATE_DIR/window_switcher_state"
echo "$PROFILE" > "$STATE_DIR/profile"

jq -r '.binds.modeSwitch | to_entries[] | "\(.key) \(.value)"' "$CONFIG_FILE" | while read -r mode key; do
    hyprctl keyword bindni $key,exec,"HYPRMCSR_PROFILE=\"$HYPRMCSR_PROFILE\" $SCRIPT_DIR/toggle_mode.sh $mode"
done

toggle_binds_key=$(jq -r '.binds.toggleBinds' "$CONFIG_FILE")
if [ -n "$toggle_binds_key" ] && [ "$toggle_binds_key" != "null" ]; then
  hyprctl keyword bind $toggle_binds_key,exec,"HYPRMCSR_PROFILE=\"$HYPRMCSR_PROFILE\" $SCRIPT_DIR/toggle_binds.sh"
fi

# Prism/Minecraft-Variablen bereitstellen
PRISM_INSTANCE_ID=$(jq -r '.minecraft.prismInstanceId' "$CONFIG_FILE")
PRISM_PREFIX=$(jq -r '.minecraft.prismPrefixOverride // "~/.local/share/PrismLauncher"' "$CONFIG_FILE")
PRISM_PREFIX="${PRISM_PREFIX/#\~/$HOME}"
MINECRAFT_ROOT="$PRISM_PREFIX/instances/$PRISM_INSTANCE_ID/.minecraft"

export PRISM_INSTANCE_ID
export MINECRAFT_ROOT


# prismReplaceWrapperCommand auswerten
PRISM_REPLACE_WRAPPER_ENABLED=$(jq -r '.minecraft.prismReplaceWrapperCommand.enabled // true' "$CONFIG_FILE")

if [ "$PRISM_REPLACE_WRAPPER_ENABLED" = "true" ]; then
  INSTANCE_CFG="$PRISM_PREFIX/instances/$PRISM_INSTANCE_ID/instance.cfg"
  INSTANCE_WRAPPER="$SCRIPT_DIR/instance_wrapper.sh"
  INNER_WRAPPER_CMD=$(jq -r '.minecraft.prismReplaceWrapperCommand.innerWrapperCommand // empty' "$CONFIG_FILE")
  if [ -n "$INNER_WRAPPER_CMD" ] && [ "$INNER_WRAPPER_CMD" != "null" ]; then
    # Schreibe instance_wrapper.sh als WrapperCommand und setze innerWrapperCommand in die Config
    if [ -f "$INSTANCE_CFG" ]; then
      if grep -q "^WrapperCommand=" "$INSTANCE_CFG"; then
        sed -i "s|^WrapperCommand=.*|WrapperCommand=$INSTANCE_WRAPPER|" "$INSTANCE_CFG"
      else
        echo "WrapperCommand=$INSTANCE_WRAPPER" >> "$INSTANCE_CFG"
      fi
    fi
    # Schreibe innerWrapperCommand in die profile.json (optional, falls du es im Wrapper brauchst)
    # jq '.minecraft.wrapperCommand = "'"$INNER_WRAPPER_CMD"'"' ... (optional)
  fi
fi

# Minecraft autostart (can be disabled in profile config)
MC_AUTOSTART=$(jq -r '.minecraft.autoStart // true' "$CONFIG_FILE")
if [ "$MC_AUTOSTART" = "true" ]; then
  prismlauncher -l "$PRISM_INSTANCE_ID" & # Start Minecraft
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
WINDOW_ADDRESS=$(cat "$STATE_DIR/window_address" 2>/dev/null || echo "")
on_start_cmds=$(jq -r '.onStart[]?' "$CONFIG_FILE")
if [ -n "$on_start_cmds" ]; then
  (
    export SCRIPT_DIR PROFILE HYPRMCSR_PROFILE PRISM_INSTANCE_ID MINECRAFT_ROOT WINDOW_ADDRESS
    while IFS= read -r cmd; do
      bash -c "$cmd" &
    done <<< "$on_start_cmds"
  )
fi

OBSERVE_LOG=$(jq -r '.minecraft.observeLog.enabled // 1' "$CONFIG_FILE")
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
  # Trap für SIGINT und SIGTERM setzen
  trap 'kill $LOG_MONITOR_PID 2>/dev/null; $SCRIPT_DIR/destroy.sh; exit' SIGINT SIGTERM
  echo "Drücke Strg+C zum Beenden. Beim Beenden wird destroy.sh automatisch ausgeführt."
  sleep infinity
fi
