#!/bin/bash
set -e

# Verzeichnis des Repos bestimmen (ein Verzeichnis über dem Skript)
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
REPO_DIR="$(realpath "$SCRIPT_DIR/..")"

REPO="Relacibo/hyprmcsr"

# Prüfe, ob git-Repo und git vorhanden
if [ -d "$REPO_DIR/.git" ] && command -v git >/dev/null 2>&1; then
  echo "Git-Repository erkannt. Aktualisiere über git ..."
  cd "$REPO_DIR"
  git fetch --tags origin
  LATEST_TAG=$(git tag --sort=-v:refname | head -n1)
  if [ -z "$LATEST_TAG" ]; then
    echo "Kein Tag gefunden! Breche ab."
    exit 1
  fi
  git checkout "$LATEST_TAG"
  echo "Update abgeschlossen auf Version: $LATEST_TAG (per git checkout) im Verzeichnis: $REPO_DIR"
  exit 0
fi

# Fallback: Release-Tarball herunterladen und entpacken
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

echo "Update abgeschlossen im Verzeichnis: $REPO_DIR (per tarball)"
