#!/bin/bash
# filepath: /home/reinhard/git/hyprmcsr/scripts/instance_wrapper.sh

export SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")
source "$SCRIPT_DIR/../util/env_core.sh"
source "$SCRIPT_DIR/../util/env_prism.sh"
source "$SCRIPT_DIR/../util/env_runtime.sh"
# Source env scripts from util
WINDOW_CLASS_REGEX=$(jq -r '.minecraft.windowClassRegex // empty' "$PROFILE_CONFIG_FILE")
WINDOW_TITLE_REGEX=$(jq -r '.minecraft.windowTitleRegex // empty' "$PROFILE_CONFIG_FILE")

# Before start: remember all Java PIDs
before_pids=$(pgrep -u "$USER" java | sort -n)
# Before start: remember all sink-input-IDs
before_sinks=$(pactl -f json list sink-inputs | jq '.[].index' | sort -n)

# Set and persist PRISM_INSTANCE_ID and MINECRAFT_ROOT from PrismLauncher environment variables
if [ -n "$INST_ID" ]; then
  PRISM_INSTANCE_ID="$INST_ID"
  echo "$PRISM_INSTANCE_ID" > "$STATE_DIR/prism_instance_id"
fi
if [ -n "$INST_MC_DIR" ]; then
  MINECRAFT_ROOT="$INST_MC_DIR"
  echo "$MINECRAFT_ROOT" > "$STATE_DIR/minecraft_root"
fi
export PRISM_INSTANCE_ID
export MINECRAFT_ROOT

# Export all relevant environment variables for child processes
SCRIPT_DIR="${SCRIPT_DIR:-$(dirname "$0")}"
source "$SCRIPT_DIR/../util/export_env.sh"

# Start parallel actions in subprocess
(
  timeout=20
  use_fallback_after=15
  elapsed=0
  window_address=""
  window_pid=""
  MC_PID=""

  # Search for new Java PID and window with matching class/title
  while [ $elapsed -lt $timeout ]; do
    clients_json=$(hyprctl clients -j)
    
    # First 15 seconds: Try to match by new Java PIDs
    if [ $elapsed -lt 15 ]; then
      after_pids=$(pgrep -u "$USER" java | sort -n)
      new_pids=$(comm -13 <(echo "$before_pids") <(echo "$after_pids"))
      
      if [ -n "$new_pids" ]; then
        echo "[hyprmcsr] New Java PIDs detected: $(echo $new_pids | tr '\n' ' ')"
      fi
      
      for pid in $new_pids; do
        window_info=$(echo "$clients_json" | jq -r --arg pid "$pid" --arg class_regex "$WINDOW_CLASS_REGEX" --arg title_regex "$WINDOW_TITLE_REGEX" '
          .[] | select(
            .pid == ($pid | tonumber)
            and (
              (
                ($class_regex == "" or $class_regex == null or (.class | test($class_regex)))
                and
                ($title_regex == "" or $title_regex == null or (.title | test($title_regex)))
              )
            )
          ) | "\(.address) \(.pid)"
        ')
        window_address=$(echo "$window_info" | awk '{print $1}')
        window_pid=$(echo "$window_info" | awk '{print $2}')
        if [ -n "$window_address" ]; then
          MC_PID="$pid"
          echo "$window_address" > "$STATE_DIR/window_address"
          echo "[hyprmcsr] Minecraft window found - PID: $MC_PID, Address: $window_address"
          break 2
        fi
      done
    else
      # After 15 seconds: Use fallback - search by class/title regex only
      if [ -n "$WINDOW_CLASS_REGEX" ] || [ -n "$WINDOW_TITLE_REGEX" ]; then
        if [ $elapsed -eq 15 ]; then
          echo "[hyprmcsr] Using fallback window detection (by regex only)"
        fi
        
        window_info=$(echo "$clients_json" | jq -r --arg class_regex "$WINDOW_CLASS_REGEX" --arg title_regex "$WINDOW_TITLE_REGEX" '
          .[] | select(
            (
              ($class_regex == "" or $class_regex == null or (.class | test($class_regex)))
              and
              ($title_regex == "" or $title_regex == null or (.title | test($title_regex)))
            )
          ) | "\(.address) \(.pid)"
        ' | head -n1)
        
        window_address=$(echo "$window_info" | awk '{print $1}')
        window_pid=$(echo "$window_info" | awk '{print $2}')
        if [ -n "$window_address" ]; then
          MC_PID="$window_pid"
          echo "$window_address" > "$STATE_DIR/window_address"
          echo "[hyprmcsr] Minecraft window found (fallback) - PID: $MC_PID, Address: $window_address"
          break
        fi
      fi
    fi
    
    sleep 1
    elapsed=$((elapsed + 1))
  done

  if [ -z "$window_address" ]; then
    echo "[hyprmcsr] Warning: Minecraft window not found within ${timeout}s timeout"
  fi

  if [ -n "$window_address" ]; then
    hyprctl -q --batch "
      dispatch setprop address:$window_address noanim 1;
      dispatch setprop address:$window_address norounding 1;
      dispatch focuswindow address:$window_address;
      dispatch setfloating address:$window_address;
      dispatch centerwindow address:$window_address;
    "
  fi

  # Sound splitting: search for new sink-input with node.name == "java" AND media.role == "game"
  # Check if audio splitting is enabled by checking for the config file
  SPLIT_AUDIO_CONF="${XDG_CONFIG_HOME:-$HOME/.config}/pipewire/pipewire.conf.d/split-audio.conf"
  if [ -f "$SPLIT_AUDIO_CONF" ]; then
    for i in {1..20}; do
      after_sinks=$(pactl -f json list sink-inputs | jq '.[].index' | sort -n)
      new_sinks=$(comm -13 <(echo "$before_sinks") <(echo "$after_sinks"))
      for new_sink in $new_sinks; do
        sink_info=$(pactl -f json list sink-inputs | jq -r --arg idx "$new_sink" '
          .[] | select(
            .index == ($idx | tonumber)
            and (.properties."node.name" // "" | test("java"; "i"))
            and (.properties."media.role" // "" | test("game"; "i"))
          )
        ')
        if [ -n "$sink_info" ]; then
          pactl move-sink-input "$new_sink" virtual_game
          break 2  # exit both loops
        fi
      done
      before_sinks="$after_sinks"   # Update reference for next round
      sleep 1
    done
  fi

  # Run minecraft.onStart (all in background, with all relevant environment variables)
  export HYPRMCSR_PROFILE PROFILE HYPRMCSR STATE_DIR PRISM_PREFIX MINECRAFT_ROOT PRISM_INSTANCE_ID WINDOW_ADDRESS
  mc_on_start_cmds=$(jq -c '.minecraft.onStart[]?' "$PROFILE_CONFIG_FILE")
  if [ -n "$mc_on_start_cmds" ]; then
    while IFS= read -r cmd; do
      "$SCRIPT_DIR/../util/run_conditional_command.sh" "$cmd"
    done <<< "$mc_on_start_cmds"
  fi
) &

# Start Minecraft directly with the given arguments (no inner_wrapper_cmd anymore)
exec "$@"

