#!/bin/bash
set -e

# Determine repo directory (one level above this script)
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
REPO_DIR="$(realpath "$SCRIPT_DIR/..")"

REPO="Relacibo/hyprmcsr"

# Check if git repo and git are available
if [ -d "$REPO_DIR/.git" ] && command -v git >/dev/null 2>&1; then
  echo "Git repository detected. Updating via git ..."
  cd "$REPO_DIR"
  git fetch --tags origin
  LATEST_TAG=$(git tag --sort=-v:refname | head -n1)
  if [ -z "$LATEST_TAG" ]; then
    echo "No tag found! Aborting."
    exit 1
  fi
  git checkout "$LATEST_TAG"
  echo "Update completed to version: $LATEST_TAG (via git checkout) in directory: $REPO_DIR"
  exit 0
fi

# Fallback: Download and extract release tarball
ASSET_URL=$(curl -s https://api.github.com/repos/$REPO/releases/latest | jq -r '.tarball_url')

if [ -z "$ASSET_URL" ] || [ "$ASSET_URL" = "null" ]; then
  echo "No release archive found!"
  exit 1
fi

echo "Downloading release: $ASSET_URL"
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"
curl -L -o latest.tar.gz "$ASSET_URL"

# Extract into repo directory (overwrites existing files)
tar -xzf latest.tar.gz -C "$REPO_DIR" --strip-components=1

cd "$REPO_DIR"
rm -rf "$TMP_DIR"

echo "Update completed in directory: $REPO_DIR (via tarball)"
