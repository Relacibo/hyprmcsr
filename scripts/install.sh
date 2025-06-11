#!/bin/bash

SCRIPT_PATH=$(dirname $(realpath "$0"))
CONFIG_FILE="$SCRIPT_PATH/config.json"
TEMPLATE_FILE="$SCRIPT_PATH/split-audio.conf"
TARGET_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/pipewire/pipewire.conf.d"
TARGET_FILE="$TARGET_DIR/split-audio.conf"

JARS_DIR="$SCRIPT_PATH/../jars"
# Liste der GitHub-Repos (owner/repo)
JAR_REPOS=(
  "tildejustin/modcheck"
  "Ninjabrain1/Ninjabrain-Bot"
  "DuncanRuns/NinjaLink"
)

# Wert aus config.json holen
PW_TARGET=$(jq -r '.pipewireLoopbackPlaybackTarget' "$CONFIG_FILE")

if [ -z "$PW_TARGET" ] || [ "$PW_TARGET" = "null" ]; then
  echo "pipewireLoopbackPlaybackTarget fehlt in config.json!"
  exit 1
fi

mkdir -p "$TARGET_DIR"

# Template ersetzen und schreiben
sed "s|{{PW_TARGET}}|$PW_TARGET|g" "$TEMPLATE_FILE" > "$TARGET_FILE"

echo "split-audio.conf wurde mit Ziel $PW_TARGET nach $TARGET_FILE geschrieben."

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
