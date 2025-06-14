#!/bin/bash
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "$SCRIPT_DIR/env_prism.sh"
source "$SCRIPT_DIR/env_runtime.sh"
WINDOW_TITLE_REGEX=$(jq -r '.minecraft.windowTitleRegex // "Minecraft"' "$CONFIG_FILE")

# Starte Minecraft (ggf. mit innerem Wrapper) und ermittle die PID
inner_wrapper_cmd=$(jq -r '.minecraft.prismReplaceWrapperCommand.innerWrapperCommand // empty' "$CONFIG_FILE")

if [ -n "$inner_wrapper_cmd" ] && [ "$inner_wrapper_cmd" != "null" ] && [ "$inner_wrapper_cmd" != "empty" ]; then
  echo "hyprmcsr: Using inner wrapper command: $inner_wrapper_cmd"
  $inner_wrapper_cmd "$@" &
else
  echo "hyprmcsr: Calling minecraft without wrapper command."
  "$@" &
fi

MC_PID=$!
echo "hyprmcsr: Started Minecraft with PID $MC_PID"

# Starte parallele Aktionen im Subprozess
(
  timeout=20
  elapsed=0
  window_address=""
  window_pid=""

  # Suche das Fenster mit passender PID
  while [ $elapsed -lt $timeout ]; do
    window_info=$(hyprctl clients -j | jq -r --arg pid "$MC_PID" '
      .[] | select(.pid == ($pid | tonumber)) | "\(.address) \(.pid)"
    ')
    window_address=$(echo "$window_info" | awk '{print $1}')
    window_pid=$(echo "$window_info" | awk '{print $2}')
    if [ -n "$window_address" ]; then
      echo "$window_address" > "$STATE_DIR/window_address"
      break
    fi
    sleep 1
    elapsed=$((elapsed + 1))
  done

  if [ -n "$window_address" ]; then
    hyprctl --batch "
      dispatch setprop address:$window_address noanim 1;
      dispatch setprop address:$window_address norounding 1
    "
  fi

  # Sound-Splitting: Suche nach sink-input mit passender PID
  pipewire_enabled=$(jq -r '.pipewireLoopback.enabled // false' "$CONFIG_FILE")
  if [ "$pipewire_enabled" = "true" ]; then
    for i in {1..20}; do
      sink_input_id=$(pactl -f json list sink-inputs | jq -r --arg pid "$MC_PID" '
        .[] | select(
          ((.properties."application.process.id" // "")|tostring) == $pid
        ) | .index
      ' | head -n1)
      if [ -n "$sink_input_id" ]; then
        pactl move-sink-input "$sink_input_id" virtual_game
        echo "hyprmcsr: Moved sink-input $sink_input_id (PID $MC_PID) to virtual_game"
        break
      fi
      sleep 1
    done
  fi

  # minecraft.onStart ausführen (alle im Hintergrund, mit allen relevanten Umgebungsvariablen)
  mc_on_start_cmds=$(jq -r '.minecraft.onStart[]?' "$CONFIG_FILE")
  if [ -n "$mc_on_start_cmds" ]; then
    (
      export SCRIPT_DIR HYPRMCSR_PROFILE PRISM_INSTANCE_ID MINECRAFT_ROOT WINDOW_ADDRESS
      while IFS= read -r cmd; do
        bash -c "$cmd" &
      done <<< "$mc_on_start_cmds"
    )
  fi
) &

# Warten auf Minecraft-Prozess
wait $MC_PID
