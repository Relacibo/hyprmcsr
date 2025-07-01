#!/bin/bash
set -e

# Verzeichnis des Repos bestimmen (ein Verzeichnis über dem Skript)
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
REPO_DIR="$(realpath "$SCRIPT_DIR/..")"

REPO="Relacibo/hyprmcsr"

# Hole die neueste Release-Tarball-URL direkt per jq
ASSET_URL=$(curl -s https://api.github.com/repos/$REPO/releases/latest | jq -r '.tarball_url')

if [ -z "$ASSET_URL" ] || [ "$ASSET_URL" = "null" ]; then
  echo "Kein Release-Archiv gefunden!"
  exit 1
fi

echo "Lade Release: $ASSET_URL"
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"
curl -L -o latest.tar.gz "$ASSET_URL"

# Entpacke ins Repo-Verzeichnis (überschreibt vorhandene Dateien)
tar -xzf latest.tar.gz -C "$REPO_DIR" --strip-components=1

cd "$REPO_DIR"
rm -rf "$TMP_DIR"

echo "Update abgeschlossen im Verzeichnis: $REPO_DIR"
