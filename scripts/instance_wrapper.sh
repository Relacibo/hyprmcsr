#!/bin/bash
source "$(dirname "$(realpath "$0")")/env_setup.sh"

# Starte parallele Aktionen im Subprozess
(
  WINDOW_ADDRESS_FILE="$STATE_DIR/window_address"
  PRISM_INSTANCE_ID=$(jq -r '.minecraft.prismInstanceId' "$CONFIG_FILE")
  PRISM_PREFIX=$(jq -r '.minecraft.prismPrefixOverride // "~/.local/share/PrismLauncher"' "$CONFIG_FILE")
  PRISM_PREFIX="${PRISM_PREFIX/#\~/$HOME}"
  MINECRAFT_ROOT="$PRISM_PREFIX/instances/$PRISM_INSTANCE_ID/.minecraft"
  window_regex=$(jq -r '.minecraft.windowTitleRegex' "$CONFIG_FILE")

  export HYPRMCSR_PROFILE
  export PRISM_INSTANCE_ID
  export MINECRAFT_ROOT

  timeout=20
  elapsed=0
  window_address=""
  window_pid=""

  while [ $elapsed -lt $timeout ]; do
    window_info=$(hyprctl clients -j | jq -r --arg regex "$window_regex" '
      .[] | select(.title | test($regex)) | "\(.address) \(.pid)"
    ')
    window_address=$(echo "$window_info" | awk '{print $1}')
    window_pid=$(echo "$window_info" | awk '{print $2}')
    if [ -n "$window_address" ]; then
      echo "$window_address" > "$WINDOW_ADDRESS_FILE"
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

  pipewire_enabled=$(jq -r '.pipewireLoopback.enabled // false' "$CONFIG_FILE")
  if [ "$pipewire_enabled" = "true" ]; then
    for i in {1..20}; do
      sink_input_id=$(pactl -f json list sink-inputs | jq -r '
        .[] | select(
          ((.properties."application.name" == "java") or (.properties."node.name" == "java"))
          and ((.properties."media.role" // "" | ascii_downcase) == "game")
        ) | .index
      ' | head -n1)
      if [ -n "$sink_input_id" ]; then
        pactl move-sink-input "$sink_input_id" virtual_game
        echo "Minecraft-Sound auf virtual_game umgeleitet."
        break
      fi
      sleep 1
    done
  fi

  # minecraft.onStart ausführen (alle im Hintergrund, mit allen relevanten Umgebungsvariablen)
  mc_on_start_cmds=$(jq -r '.minecraft.onStart[]?' "$CONFIG_FILE")
  if [ -n "$mc_on_start_cmds" ]; then
    (
      export SCRIPT_DIR PROFILE HYPRMCSR_PROFILE PRISM_INSTANCE_ID MINECRAFT_ROOT WINDOW_ADDRESS
      while IFS= read -r cmd; do
        bash -c "$cmd" &
      done <<< "$mc_on_start_cmds"
    )
  fi
) &

wrapper_cmd=$(jq -r '.minecraft.wrapperCommand // empty' "$CONFIG_FILE")
if [ -n "$wrapper_cmd" ] && [ "$wrapper_cmd" != "default" ] && [ "$wrapper_cmd" != "null" ]; then
  exec $wrapper_cmd "$@"
else
  exec $@
fi
