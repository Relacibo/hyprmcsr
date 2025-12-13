#!/bin/bash

export SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")
CONFIG_ROOT="${XDG_CONFIG_HOME:-$HOME/.config}/hyprmcsr"
REPOSITORIES_FILE="$CONFIG_ROOT/repositories.json"
EXAMPLE_REPOSITORIES="$SCRIPT_DIR/../example.repositories.json"

mkdir -p "$CONFIG_ROOT"

# Migration: convert old config.json to repositories.json
OLD_CONFIG_FILE="$CONFIG_ROOT/config.json"
if [ -f "$OLD_CONFIG_FILE" ] && [ ! -f "$REPOSITORIES_FILE" ]; then
  echo "Migrating config.json to repositories.json..."
  if command -v jq &>/dev/null; then
    # Extract jar config from various possible locations
    jar_data=$(jq -r '
      if .download.jar then
        # .download.jar exists - use it (object or string)
        if (.download.jar | type) == "string" then
          # String: wrap as single "default" entry
          { jar: { default: .download.jar } }
        else
          # Object: use as-is
          { jar: .download.jar }
        end
      elif .jar then
        # Direct .jar on root level
        { jar: .jar }
      else
        # No jar config found
        { jar: {} }
      end
    ' "$OLD_CONFIG_FILE")
    
    if echo "$jar_data" | jq . > "$REPOSITORIES_FILE" 2>/dev/null; then
      echo "Migration complete. You can safely delete $OLD_CONFIG_FILE"
    else
      echo "Error: Migration failed. Please check $OLD_CONFIG_FILE format."
      rm -f "$REPOSITORIES_FILE"
    fi
  else
    echo "Warning: jq not found, cannot auto-migrate config.json"
  fi
fi

# Copy example repositories if still no repositories.json exists
if [ ! -f "$REPOSITORIES_FILE" ]; then
  cp "$EXAMPLE_REPOSITORIES" "$REPOSITORIES_FILE"
  echo "Copied example.repositories.json to $REPOSITORIES_FILE."
fi

if [ $# -lt 1 ]; then
  echo "Usage: $0 <jar_name> [args...]"
  echo "  jar_name: Name from repositories.json (e.g., 'ninjabrain-bot', 'modcheck')"
  exit 1
fi

if ! command -v java &>/dev/null; then
  echo "Error: java is not installed or not in PATH"
  exit 1
fi

JAR_NAME="$1"
shift

# Download root, read from profile config if present, else default
source "$SCRIPT_DIR/../util/env_core.sh"
DOWNLOAD_ROOT=$(jq -r '.downloadRoot // empty' "$PROFILE_CONFIG_FILE")
if [ -z "$DOWNLOAD_ROOT" ] || [ "$DOWNLOAD_ROOT" = "null" ]; then
  DOWNLOAD_ROOT=$(realpath "$SCRIPT_DIR/../download")
fi
JARS_DIR="$DOWNLOAD_ROOT/jar"
mkdir -p "$JARS_DIR"

# Try to find JAR repo - supports unique prefix matching
JAR_REPO=""
if [ -f "$REPOSITORIES_FILE" ]; then
  # Try exact match first
  JAR_REPO=$(jq -r --arg name "$JAR_NAME" '.jar[$name] // empty' "$REPOSITORIES_FILE")
  
  if [ -z "$JAR_REPO" ] || [ "$JAR_REPO" = "null" ]; then
    # Try prefix match
    matches=$(jq -r --arg prefix "$JAR_NAME" '.jar | to_entries[] | select(.key | startswith($prefix)) | .key' "$REPOSITORIES_FILE")
    if [ -z "$matches" ]; then
      match_count=0
    else
      match_count=$(echo "$matches" | wc -l | tr -d '[:space:]')
    fi
    
    if [ "$match_count" -eq 1 ]; then
      matched_key=$(echo "$matches" | head -n1)
      JAR_REPO=$(jq -r --arg key "$matched_key" '.jar[$key]' "$REPOSITORIES_FILE")
      echo "Using JAR: $matched_key"
    elif [ "$match_count" -gt 1 ]; then
      echo "Error: Ambiguous prefix '$JAR_NAME'. Matches:"
      echo "$matches"
      exit 1
    fi
  fi
fi

if [ -z "$JAR_REPO" ] || [ "$JAR_REPO" = "null" ]; then
  echo "Error: JAR '$JAR_NAME' not found in repositories.json"
  echo "Please add it to the 'jar' section in $REPOSITORIES_FILE"
  echo "Example: \"$JAR_NAME\": \"owner/repo\""
  exit 1
fi

# Download/update JAR if it's a GitHub repo
JAR_FILE=""
if [[ "$JAR_REPO" == */* ]]; then
  # GitHub repo (owner/repo)
  api_url="https://api.github.com/repos/$JAR_REPO/releases/latest"
  release_json=$(curl -s "$api_url")
  jar_url=$(echo "$release_json" | jq -r '.assets[] | select(.name | endswith(".jar")) | .browser_download_url' | head -n1)
  
  if [ -n "$jar_url" ] && [ "$jar_url" != "null" ]; then
    jar_name=$(basename "$jar_url")
    repo_prefix=$(basename "$JAR_REPO")
    
    # Check if we already have this exact version
    if [ -f "$JARS_DIR/$jar_name" ]; then
      echo "$jar_name already up to date."
      JAR_FILE="$JARS_DIR/$jar_name"
    else
      # Try to download new version
      echo "New version available: $jar_name"
      echo "Downloading $jar_url..."
      if curl -L "$jar_url" -o "$JARS_DIR/$jar_name" 2>/dev/null; then
        # Remove old versions after successful download
        find "$JARS_DIR" -type f -name "${repo_prefix}-*.jar" ! -name "$jar_name" -exec rm {} \;
        echo "Download successful."
        JAR_FILE="$JARS_DIR/$jar_name"
      else
        echo "Warning: Download failed. Checking for existing version..."
        # Try to find any existing version
        JAR_FILE=$(find "$JARS_DIR" -maxdepth 1 -type f -name "${repo_prefix}-*.jar" | head -n1)
        if [ -z "$JAR_FILE" ]; then
          echo "Error: No local version available and download failed."
          exit 2
        fi
        echo "Using existing version: $(basename "$JAR_FILE")"
      fi
    fi
  else
    # API call failed or no JAR in release, try to use existing
    echo "Warning: Could not fetch latest release information."
    repo_prefix=$(basename "$JAR_REPO")
    JAR_FILE=$(find "$JARS_DIR" -maxdepth 1 -type f -name "${repo_prefix}-*.jar" | head -n1)
    if [ -z "$JAR_FILE" ]; then
      echo "Error: No local version available and could not fetch remote information."
      exit 2
    fi
    echo "Using existing version: $(basename "$JAR_FILE")"
  fi
else
  echo "Error: Invalid repository format for '$JAR_NAME': $JAR_REPO"
  echo "Expected format in repositories.json: \"$JAR_NAME\": \"owner/repo\""
  echo "Example: \"ninjabrain-bot\": \"Ninjabrain1/Ninjabrain-Bot\""
  exit 3
fi

# Determine working directory
WORKDIR="${JAR_WORKDIR:-/tmp/hyprmcsr-jar}"
mkdir -p "$WORKDIR"
cd "$WORKDIR"

java -jar "$JAR_FILE" "$@"
