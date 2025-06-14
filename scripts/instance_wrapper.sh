#!/bin/bash
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "$SCRIPT_DIR/env_prism.sh"
source "$SCRIPT_DIR/env_runtime.sh"
WINDOW_TITLE_REGEX=$(jq -r '.minecraft.windowTitleRegex // "Minecraft"' "$CONFIG_FILE")

# Vor dem Start: Liste aller Java-PIDs merken
before_pids=$(pgrep -u "$USER" java | sort)
# Vor dem Start: Liste aller sink-input-IDs merken
before_sinks=$(pactl -f json list sink-inputs | jq '.[].index' | sort)

# Starte parallele Aktionen im Subprozess
(
  timeout=20
  elapsed=0
  window_address=""
  window_pid=""
  MC_PID=""

  # Suche nach neuer Java-PID und Fenster mit passendem Titel
  while [ $elapsed -lt $timeout ]; do
    after_pids=$(pgrep -u "$USER" java | sort)
    new_pid=$(comm -13 <(echo "$before_pids") <(echo "$after_pids") | head -n1)
    if [ -n "$new_pid" ]; then
      window_info=$(hyprctl clients -j | jq -r --arg pid "$new_pid" --arg regex "$WINDOW_TITLE_REGEX" '
        .[] | select(.pid == ($pid | tonumber) and (.title | test($regex))) | "\(.address) \(.pid)"
      ')
      window_address=$(echo "$window_info" | awk '{print $1}')
      window_pid=$(echo "$window_info" | awk '{print $2}')
      if [ -n "$window_address" ]; then
        MC_PID="$new_pid"
        echo "$window_address" > "$STATE_DIR/window_address"
        break
      fi
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

  # Sound-Splitting: Suche nach neuem sink-input mit "Minecraft", "java" oder "game" im Namen/Role
  pipewire_enabled=$(jq -r '.pipewireLoopback.enabled // false' "$CONFIG_FILE")
  if [ "$pipewire_enabled" = "true" ]; then
    for i in {1..20}; do
      after_sinks=$(pactl -f json list sink-inputs | jq '.[].index' | sort)
      new_sink=$(comm -13 <(echo "$before_sinks") <(echo "$after_sinks") | head -n1)
      if [ -n "$new_sink" ]; then
        sink_info=$(pactl -f json list sink-inputs | jq -r --arg idx "$new_sink" '.[] | select(.index == ($idx | tonumber))')
        name_check=$(echo "$sink_info" | jq -r '(.properties."application.name" // "") + " " + (.properties."media.name" // "")')
        node_name=$(echo "$sink_info" | jq -r '.properties."node.name" // ""')
        media_role=$(echo "$sink_info" | jq -r '.properties."media.role" // ""')
        if echo "$name_check $node_name $media_role" | grep -Eqi "minecraft|java|game"; then
          pactl move-sink-input "$new_sink" virtual_game
          break
        fi
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

# Starte Minecraft (ggf. mit innerem Wrapper) im Vordergrund!
inner_wrapper_cmd=$(jq -r '.minecraft.prismWrapperCommand.innerCommand // empty' "$CONFIG_FILE")

if [ -n "$inner_wrapper_cmd" ] && [ "$inner_wrapper_cmd" != "null" ] && [ "$inner_wrapper_cmd" != "empty" ]; then
  exec $inner_wrapper_cmd "$@"
else
  exec "$@"
fi
