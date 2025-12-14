#!/bin/bash

# Check for required and optional dependencies

echo "=== Checking hyprmcsr dependencies ==="
echo ""

MISSING_REQUIRED=()
MISSING_OPTIONAL=()

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
check_required "inotifywait" "inotify-tools"
check_required "prismlauncher" "prismlauncher"

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
