#!/bin/bash
# Shared check for keybind-triggered actions (mode switches, custom binds).
#
# The state observer updates binds_enabled and the mode asynchronously, so a
# keypress that follows a reset can race the observer: the wall is already on
# screen while the old mode/bind state is still in effect. Instead of trusting
# the derived files, check the live Hermes state at keypress time.
#
# Entering the wall locks mode switching for a short moment (WALL_LOCK_MS,
# default 1s) so the muscle-memory mode press right after a reset is ignored.
# After that the wall is toggleable again as soon as binds are enabled.
#
# Source this file after env_prism.sh/env_runtime.sh, then call binds_allowed.

# How long mode switching stays locked after the wall state appears.
WALL_LOCK_MS="${HYPRMCSR_WALL_LOCK_MS:-1000}"

state_file_is_fresh() {
  local mtime now
  mtime=$(date -r "$1" +%s%N 2>/dev/null) || return 1
  now=$(date +%s%N)
  [ $(( (now - mtime) / 1000000 )) -lt "$WALL_LOCK_MS" ]
}

binds_allowed() {
  [ "${BINDS_ENABLED:-0}" = "1" ] || return 1

  if [ -n "${MINECRAFT_ROOT:-}" ] && [ -f "$MINECRAFT_ROOT/hermes/state.json" ]; then
    local file="$MINECRAFT_ROOT/hermes/state.json" json screen
    # Read once so a concurrent Hermes rewrite cannot mix two states. Invalid
    # JSON (mid-write) must block the keypress, not let it through.
    json=$(cat "$file" 2>/dev/null) || return 1
    screen=$(printf '%s' "$json" | jq -r '.screen.class // empty' 2>/dev/null) || return 1
    if [ "$screen" = "me.contaria.seedqueue.gui.wall.SeedQueueWallScreen" ]; then
      state_file_is_fresh "$file" && return 1
    fi
  elif [ -n "${MINECRAFT_ROOT:-}" ] && [ -f "$MINECRAFT_ROOT/wpstateout.txt" ]; then
    local file="$MINECRAFT_ROOT/wpstateout.txt"
    if [ "$(cat "$file" 2>/dev/null)" = "wall" ]; then
      state_file_is_fresh "$file" && return 1
    fi
  fi

  return 0
}
