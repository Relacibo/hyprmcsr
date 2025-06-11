#!/bin/bash

SCRIPT_PATH=$(dirname $(realpath "$0"))
CONFIG_FILE="$SCRIPT_PATH/../config.json"
TEMPLATE_FILE="$SCRIPT_PATH/../split-audio.conf"
PIPEWIRE_CONFIG_FOLDER="${XDG_CONFIG_HOME:-$HOME/.config}/pipewire/pipewire.conf.d"
PW_ENABLED=$(jq -r '.pipewireLoopback.enabled' "$CONFIG_FILE")
SPLIT_AUDIO_CONF="$PIPEWIRE_CONFIG_FOLDER/split-audio.conf"

JARS_DIR="$SCRIPT_PATH/../jars"
# Liste der GitHub-Repos (owner/repo)
JAR_REPOS=(
  "tildejustin/modcheck"
  "Ninjabrain1/Ninjabrain-Bot"
  "DuncanRuns/NinjaLink"
)


if [ "$PW_ENABLED" = "0" ]; then
  if [ -f "$SPLIT_AUDIO_CONF" ]; then
    rm "$SPLIT_AUDIO_CONF"
    echo "split-audio.conf removed (pipewireLoopback disabled)."
  fi
else
  # Wert aus config.json holen
  PW_TARGET=$(jq -r '.pipewireLoopback.playbackTarget' "$CONFIG_FILE")
  if [ -z "$PW_TARGET" ] || [ "$PW_TARGET" = "null" ]; then
    # Default sink ermitteln
    if command -v pactl &>/dev/null && pactl get-default-sink &>/dev/null; then
      PW_TARGET=$(pactl get-default-sink)
    else
      PW_TARGET=$(pactl info | grep "Default Sink" | awk '{print $3}')
    fi

    if [ -z "$PW_TARGET" ]; then
      echo "Konnte keinen Default Sink finden!"
      exit 1
    fi

    # playbackTarget in config.json aktualisieren
    tmp_config=$(mktemp)
    jq --arg target "$PW_TARGET" '.pipewireLoopback.playbackTarget = $target' "$CONFIG_FILE" > "$tmp_config" && mv "$tmp_config" "$CONFIG_FILE"
    echo "playbackTarget in config.json auf $PW_TARGET gesetzt."
  fi

  mkdir -p "$PIPEWIRE_CONFIG_FOLDER"
  # Template ersetzen und schreiben
  sed "s|{{PW_TARGET}}|$PW_TARGET|g" "$TEMPLATE_FILE" > "$SPLIT_AUDIO_CONF"
  echo "split-audio.conf wurde mit Ziel $PW_TARGET nach $SPLIT_AUDIO_CONF geschrieben."
fi

for repo in "${JAR_REPOS[@]}"; do
  api_url="https://api.github.com/repos/$repo/releases/latest"
  release_json=$(curl -s "$api_url")
  jar_url=$(echo "$release_json" | jq -r '.assets[] | select(.name | endswith(".jar")) | .browser_download_url' | head -n1)
  jar_name=$(basename "$jar_url")

  if [ -z "$jar_url" ] || [ "$jar_url" = "null" ]; then
    echo "Keine JAR im Latest Release von $repo gefunden."
    continue
  fi

  if [ -f "$JARS_DIR/$jar_name" ]; then
    echo "$jar_name ist bereits aktuell vorhanden."
  else
    echo "Lade $jar_url herunter..."
    curl -L "$jar_url" -o "$JARS_DIR/$jar_name"
  fi
done

echo "Alle JARs wurden überprüft und ggf. aktualisiert."
