#!/bin/bash

# Check for required and optional dependencies

echo "=== Checking hyprmcsr dependencies ==="
echo ""

MISSING_REQUIRED=()
MISSING_OPTIONAL=()

CONFIG_ROOT="${XDG_CONFIG_HOME:-$HOME/.config}/hyprmcsr"
HYPRMCSR_PROFILE="${HYPRMCSR_PROFILE:-default}"
PROFILE_CONFIG_FILE="$CONFIG_ROOT/${HYPRMCSR_PROFILE}.profile.json"

# Some dependencies are only required by optional features. Read the profile
# when it exists so `check-dependencies` reflects the actual configuration.
OBSERVE_STATE="true"
FLATPAK="false"
if command -v jq >/dev/null 2>&1 && [ -f "$PROFILE_CONFIG_FILE" ]; then
  OBSERVE_STATE=$(jq -r '.minecraft.observeState.enabled // .minecraft.observeLog.enabled // true' "$PROFILE_CONFIG_FILE" 2>/dev/null)
  FLATPAK=$(jq -r '.minecraft.prismLauncher.flatpak // false' "$PROFILE_CONFIG_FILE" 2>/dev/null)
fi

# Required dependencies
echo "Required dependencies:"

check_required() {
  local cmd=$1
  local package=$2
  
  if command -v "$cmd" >/dev/null 2>&1; then
    echo "  ✓ $cmd (found)"
  else
    echo "  ✗ $cmd (missing - install: $package)"
    MISSING_REQUIRED+=("$package")
  fi
}

check_required "jq" "jq"
check_required "hyprctl" "hyprland"
check_required "curl" "curl"
check_required "realpath" "coreutils"
check_required "setsid" "util-linux"

if [ "$OBSERVE_STATE" = "true" ]; then
  check_required "inotifywait" "inotify-tools"
else
  echo "  - inotifywait (not needed: state observation is disabled)"
fi

if [ "$FLATPAK" = "true" ]; then
  check_required "flatpak" "flatpak"
else
  check_required "prismlauncher" "prismlauncher"
fi

echo ""
echo "Optional dependencies:"

check_optional() {
  local cmd=$1
  local package=$2
  local description=$3
  
  if command -v "$cmd" >/dev/null 2>&1; then
    echo "  ✓ $cmd (found) - $description"
  else
    echo "  ✗ $cmd (missing) - $description - install: $package"
    MISSING_OPTIONAL+=("$package")
  fi
}

check_optional "pactl" "pipewire-pulse or pulseaudio-utils" "for audio splitter setup"
check_optional "java" "openjdk" "for run-jar"
check_optional "git" "git" "for updating via git"

echo ""

if [ ${#MISSING_REQUIRED[@]} -gt 0 ]; then
  echo "❌ Missing required dependencies: ${MISSING_REQUIRED[*]}"
  echo "   hyprmcsr will not work without these!"
  exit 1
elif [ ${#MISSING_OPTIONAL[@]} -gt 0 ]; then
  echo "⚠️  Missing optional dependencies: ${MISSING_OPTIONAL[*]}"
  echo "   Some features may not work."
  exit 0
else
  echo "✅ All dependencies are installed!"
  exit 0
fi
