#!/bin/bash
# Shared check for keybind-triggered actions (mode switches, custom binds).
#
# The state observer disables binds asynchronously, so when the SeedQueue wall
# opens the stored binds_enabled flag can still be 1 for a moment while the
# wall is already on screen. Cross-check the live state file so a keypress in
# that window cannot fire.
#
# Call as `binds_allowed ingame` for actions that only make sense while a world
# is loaded or loading (mode switches, like resetti's `ingame_*` keybinds). That
# also rejects the reset-to-wall transition before the wall screen itself has
# been reported, because leaving the world clears `world.path` first.
#
# Source this file after env_prism.sh/env_runtime.sh, then call binds_allowed.

binds_allowed() {
  local require_world="${1:-}"

  [ "${BINDS_ENABLED:-0}" = "1" ] || return 1

  if [ -n "${MINECRAFT_ROOT:-}" ] && [ -f "$MINECRAFT_ROOT/hermes/state.json" ]; then
    local json world screen
    # Read once so a concurrent Hermes rewrite cannot mix two states. Invalid
    # JSON (mid-write) must block the keypress, not let it through.
    json=$(cat "$MINECRAFT_ROOT/hermes/state.json" 2>/dev/null) || return 1
    world=$(printf '%s' "$json" | jq -r '.world.path // empty' 2>/dev/null) || return 1
    screen=$(printf '%s' "$json" | jq -r '.screen.class // empty' 2>/dev/null) || return 1
    [ "$screen" = "me.contaria.seedqueue.gui.wall.SeedQueueWallScreen" ] && return 1
    if [ "$require_world" = "ingame" ] && [ -z "$world" ]; then
      return 1
    fi
  elif [ -n "${MINECRAFT_ROOT:-}" ] && [ -f "$MINECRAFT_ROOT/wpstateout.txt" ]; then
    [ "$(cat "$MINECRAFT_ROOT/wpstateout.txt" 2>/dev/null)" = "wall" ] && return 1
  fi

  return 0
}
