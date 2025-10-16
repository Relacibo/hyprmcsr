#!/bin/bash
# Centers the cursor on the monitor where the Minecraft window is located
export SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")
source "$SCRIPT_DIR/../util/env_runtime.sh"

# Get the monitor ID (numeric) of the window
MONITOR_ID=$(hyprctl clients -j | jq -r ".[] | select(.address==\"$WINDOW_ADDRESS\") | .monitor")

# Get the geometry of the monitor based on the ID
read X Y WIDTH HEIGHT <<<$(hyprctl monitors -j | jq -r ".[] | select(.id==$MONITOR_ID) | \"\(.x) \(.y) \(.width) \(.height)\"")

CENTER_X=$((X + WIDTH / 2))
CENTER_Y=$((Y + HEIGHT / 2))

hyprctl dispatch movecursor "$CENTER_X" "$CENTER_Y"
