#!/bin/bash
# Centers the cursor on the monitor where the Minecraft window is located
export SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")
source "$SCRIPT_DIR/../util/env_runtime.sh"

# Get the monitor ID (numeric) of the window
MONITOR_ID=$(hyprctl clients -j | jq -r ".[] | select(.address==\"$WINDOW_ADDRESS\") | .monitor")

# Get the geometry and scale of the monitor based on the ID
read X Y WIDTH HEIGHT SCALE <<<$(hyprctl monitors -j | jq -r ".[] | select(.id==$MONITOR_ID) | \"\(.x) \(.y) \(.width) \(.height) \(.scale)\"")

# Calculate effective dimensions (divided by scale)
# Use awk for float division
EFFECTIVE_WIDTH=$(awk "BEGIN {printf \"%.0f\", $WIDTH / $SCALE}")
EFFECTIVE_HEIGHT=$(awk "BEGIN {printf \"%.0f\", $HEIGHT / $SCALE}")

CENTER_X=$((X + EFFECTIVE_WIDTH / 2))
CENTER_Y=$((Y + EFFECTIVE_HEIGHT / 2))

hyprctl -q dispatch movecursor "$CENTER_X" "$CENTER_Y"
