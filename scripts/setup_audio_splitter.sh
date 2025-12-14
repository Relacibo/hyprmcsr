#!/bin/bash

# Script to setup PipeWire audio splitter configuration
# Usage: setup_audio_splitter.sh [action] [playback_target]
#   action: enable/disable - whether to enable or disable the audio splitter (if not provided, interactive mode)
#   playback_target: optional - PipeWire sink to use (auto-detected if not provided)

SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")
TEMPLATE_FILE="$SCRIPT_DIR/../templates/split-audio.conf.template"
PIPEWIRE_CONFIG_FOLDER="${XDG_CONFIG_HOME:-$HOME/.config}/pipewire/pipewire.conf.d"
SPLIT_AUDIO_CONF="$PIPEWIRE_CONFIG_FOLDER/split-audio.conf"

# Interactive mode if no arguments provided
if [ $# -eq 0 ]; then
  echo ""
  read -p "Setup audio splitter? [y/N]: " setup_audio
  setup_audio="${setup_audio:-n}"
  
  if [[ ! "$setup_audio" =~ ^[Yy] ]]; then
    echo "Skipping audio splitter setup."
    exit 0
  fi
  
  # Check current status
  if [ -f "$SPLIT_AUDIO_CONF" ]; then
    CURRENT_STATUS="enabled"
    DEFAULT_ACTION="enabled"
    STATUS_TEXT="previous value"
  else
    CURRENT_STATUS="disabled"
    DEFAULT_ACTION="disabled"
    STATUS_TEXT="previous value"
  fi
  
  # Ask whether to enable or disable
  echo ""
  echo "Audio splitter is currently: $CURRENT_STATUS"
  read -p "Enable or disable audio splitter? ($STATUS_TEXT: $DEFAULT_ACTION) [enable/disable]: " action_input
  action_input="${action_input:-$DEFAULT_ACTION}"
  
  if [[ "$action_input" =~ ^[Dd] ]]; then
    ACTION="disable"
  elif [[ "$action_input" =~ ^[Ee] ]]; then
    ACTION="enable"
  else
    echo "Invalid choice. Please enter 'enable' or 'disable'."
    exit 1
  fi
  
  if [ "$ACTION" = "enable" ]; then
    # List available monitor sinks
    echo ""
    echo "Available monitor sinks:"
    mapfile -t SINKS < <(pactl list sinks short | awk '{print $2}')
    
    for i in "${!SINKS[@]}"; do
      echo "  $((i+1)). ${SINKS[$i]}"
    done
    echo ""
    
    DEFAULT_SINK=$(pactl get-default-sink)
    # Find default sink index
    DEFAULT_INDEX=""
    for i in "${!SINKS[@]}"; do
      if [ "${SINKS[$i]}" = "$DEFAULT_SINK" ]; then
        DEFAULT_INDEX=$((i+1))
        break
      fi
    done
    
    if [ -n "$DEFAULT_INDEX" ]; then
      read -p "Select monitor sink by number [1-${#SINKS[@]}] (default: $DEFAULT_INDEX - $DEFAULT_SINK): " sink_input
    else
      read -p "Select monitor sink by number [1-${#SINKS[@]}]: " sink_input
    fi
    
    # Check if input is a number and within range
    if [ -z "$sink_input" ] && [ -n "$DEFAULT_INDEX" ]; then
      PW_TARGET="$DEFAULT_SINK"
    elif [[ "$sink_input" =~ ^[0-9]+$ ]] && [ "$sink_input" -ge 1 ] && [ "$sink_input" -le ${#SINKS[@]} ]; then
      PW_TARGET="${SINKS[$((sink_input-1))]}"
    else
      echo "Invalid selection! Please enter a number between 1 and ${#SINKS[@]}."
      exit 1
    fi
  fi
else
  ACTION="$1"
  PW_TARGET="${2:-}"
  
  if [ "$ACTION" != "enable" ] && [ "$ACTION" != "disable" ]; then
    echo "Usage: $0 [action] [playback_target]"
    echo "  action: enable/disable (optional - if not provided, interactive mode)"
    echo "  playback_target: optional PipeWire sink (auto-detected if not provided)"
    exit 1
  fi
fi

if [ "$ACTION" = "enable" ]; then
  # Get playback target if not provided
  if [ -z "$PW_TARGET" ]; then
    # Get default sink
    PW_TARGET=$(pactl get-default-sink)

    if [ -z "$PW_TARGET" ]; then
      echo "Could not find default sink!"
      exit 1
    fi
  fi

  mkdir -p "$PIPEWIRE_CONFIG_FOLDER"
  # Replace template and write
  sed "s|{{PW_TARGET}}|$PW_TARGET|g" "$TEMPLATE_FILE" > "$SPLIT_AUDIO_CONF"
  echo "split-audio.conf written to $SPLIT_AUDIO_CONF with target $PW_TARGET."
elif [ "$ACTION" = "disable" ]; then
  if [ -f "$SPLIT_AUDIO_CONF" ]; then
    rm "$SPLIT_AUDIO_CONF"
    echo "split-audio.conf removed (audio splitter disabled)."
  fi
fi
