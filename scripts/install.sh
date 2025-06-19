#!/bin/bash

SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")
CONFIG_ROOT="${XDG_CONFIG_HOME:-$HOME/.config}/hyprmcsr"
CONFIG_FILE="$CONFIG_ROOT/config.json"
PROFILE_CONFIG_FILE="$CONFIG_ROOT/default.profile.json"
EXAMPLE_GLOBAL="$SCRIPT_DIR/../example.config.json"
EXAMPLE_PROFILE="$SCRIPT_DIR/../example.default.profile.json"
TEMPLATE_FILE="$SCRIPT_DIR/../split-audio.conf"
PIPEWIRE_CONFIG_FOLDER="${XDG_CONFIG_HOME:-$HOME/.config}/pipewire/pipewire.conf.d"
PW_ENABLED=$(jq -r '.pipewireLoopback.enabled // false' "$CONFIG_FILE" 2>/dev/null || echo "false")
SPLIT_AUDIO_CONF="$PIPEWIRE_CONFIG_FOLDER/split-audio.conf"

# Copy example configs if not present
mkdir -p "$CONFIG_ROOT"
if [ ! -f "$CONFIG_FILE" ]; then
  cp "$EXAMPLE_GLOBAL" "$CONFIG_FILE"
  echo "Copied example.config.json to $CONFIG_FILE."
fi
if [ ! -f "$PROFILE_CONFIG_FILE" ]; then
  cp "$EXAMPLE_PROFILE" "$PROFILE_CONFIG_FILE"
  echo "Copied example.default.profile.json to $PROFILE_CONFIG_FILE."
fi

if [ "$PW_ENABLED" = "true" ]; then
  # Get value from config.json
  PW_TARGET=$(jq -r '.pipewireLoopback.playbackTarget' "$CONFIG_FILE")
  if [ -z "$PW_TARGET" ] || [ "$PW_TARGET" = "null" ]; then
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

    # Update playbackTarget in config.json
    tmp_config=$(mktemp)
    jq --arg target "$PW_TARGET" '.pipewireLoopback.playbackTarget = $target' "$CONFIG_FILE" > "$tmp_config" && mv "$tmp_config" "$CONFIG_FILE"
    echo "Set playbackTarget in config.json to $PW_TARGET."
  fi
  mkdir -p "$PIPEWIRE_CONFIG_FOLDER"
  # Replace template and write
  sed "s|{{PW_TARGET}}|$PW_TARGET|g" "$TEMPLATE_FILE" > "$SPLIT_AUDIO_CONF"
  echo "split-audio.conf written to $SPLIT_AUDIO_CONF with target $PW_TARGET."
else
  if [ -f "$SPLIT_AUDIO_CONF" ]; then
    rm "$SPLIT_AUDIO_CONF"
    echo "split-audio.conf removed (pipewireLoopback disabled)."
  fi
fi

DOWNLOAD_ROOT=$(jq -r '.download.root // empty' "$CONFIG_FILE")
if [ -z "$DOWNLOAD_ROOT" ] || [ "$DOWNLOAD_ROOT" = "null" ]; then
  DOWNLOAD_ROOT="$SCRIPT_DIR/../download"
fi
JARS_DIR="$DOWNLOAD_ROOT/jar"
mkdir -p "$JARS_DIR"

mapfile -t JAR_REPOS < <(jq -r '.download.jar[]?' "$CONFIG_FILE")

for entry in "${JAR_REPOS[@]}"; do
  if [[ "$entry" == */* ]]; then
    # GitHub repo (owner/repo)
    api_url="https://api.github.com/repos/$entry/releases/latest"
    release_json=$(curl -s "$api_url")
    jar_url=$(echo "$release_json" | jq -r '.assets[] | select(.name | endswith(".jar")) | .browser_download_url' | head -n1)
    jar_name=$(basename "$jar_url")
  else
    # (Placeholder for future URL logic)
    echo "Unknown JAR source: $entry"
    continue
  fi

  if [ -z "$jar_url" ] || [ "$jar_url" = "null" ]; then
    echo "No JAR found in latest release of $entry."
    continue
  fi

  if [ -f "$JARS_DIR/$jar_name" ]; then
    echo "$jar_name already present."
  else
    echo "Downloading $jar_url..."
    curl -L "$jar_url" -o "$JARS_DIR/$jar_name"
  fi
done

echo "All JARs checked and updated if necessary."
