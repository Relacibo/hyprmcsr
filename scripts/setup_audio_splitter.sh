#!/bin/bash

# Script to setup PipeWire audio splitter configuration
# Usage: setup_audio_splitter.sh <action> [playback_target]
#   action: enable/disable - whether to enable or disable the audio splitter
#   playback_target: optional - PipeWire sink to use (auto-detected if not provided)

if [ $# -lt 1 ]; then
  echo "Usage: $0 <action> [playback_target]"
  echo "  action: enable/disable"
  echo "  playback_target: optional PipeWire sink (auto-detected if not provided)"
  exit 1
fi

SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")
TEMPLATE_FILE="$SCRIPT_DIR/../templates/split-audio.conf.template"
PIPEWIRE_CONFIG_FOLDER="${XDG_CONFIG_HOME:-$HOME/.config}/pipewire/pipewire.conf.d"
SPLIT_AUDIO_CONF="$PIPEWIRE_CONFIG_FOLDER/split-audio.conf"
ACTION="$1"
PW_TARGET="${2:-}"

if [ "$ACTION" = "enable" ]; then
  # Get playback target if not provided
  if [ -z "$PW_TARGET" ]; then
    # Get default sink
    if command -v pactl &>/dev/null && pactl get-default-sink &>/dev/null; then
      PW_TARGET=$(pactl get-default-sink)
    else
      PW_TARGET=$(pactl info | grep "Default Sink" | awk '{print $3}')
    fi

    if [ -z "$PW_TARGET" ]; then
      echo "Could not find default sink!"
      exit 1
    fi
  fi

  mkdir -p "$PIPEWIRE_CONFIG_FOLDER"
  # Replace template and write
  sed "s|{{PW_TARGET}}|$PW_TARGET|g" "$TEMPLATE_FILE" > "$SPLIT_AUDIO_CONF"
  echo "split-audio.conf written to $SPLIT_AUDIO_CONF with target $PW_TARGET."
else
  if [ -f "$SPLIT_AUDIO_CONF" ]; then
    rm "$SPLIT_AUDIO_CONF"
    echo "split-audio.conf removed (audio splitter disabled)."
  fi
fi
