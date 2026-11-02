#!/bin/bash
# Hyprland IPC compatibility helpers.
#
# Hyprland 0.57 removed the legacy hyprlang IPC: `hyprctl keyword` and the
# string-based dispatchers (`hyprctl dispatch workspace 3`) no longer work.
# 0.55/0.56 already switch to the Lua IPC protocol when they are started with a
# hyprland.lua config. Detect the active protocol through the authoritative
# `configProvider` field instead of guessing from the version, so both legacy
# and Lua-based Hyprland keep working.

hypr_config_provider() {
  if [ -z "${HYPRMCSR_CONFIG_PROVIDER+x}" ]; then
    HYPRMCSR_CONFIG_PROVIDER=$(hyprctl systeminfo 2>/dev/null | awk -F': ' '/^configProvider:/{print $2; exit}')
    export HYPRMCSR_CONFIG_PROVIDER
  fi
  printf '%s' "$HYPRMCSR_CONFIG_PROVIDER"
}

hypr_uses_lua() {
  [ "$(hypr_config_provider)" = "lua" ]
}

hypr_eval() {
  hyprctl -q eval "$1"
}

# Convert a legacy "MODS, KEY" bind spec (as stored in profile JSON) to the
# "MODS + KEY" string expected by hl.bind().
hypr_lua_key() {
  printf '%s\n' "$1" | awk -F',' '
    {
      if (index($0, ",") == 0) {
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", $0)
        print $0
        next
      }
      mods = $1
      key  = $2
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", mods)
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", key)
      if (mods == "") {
        print key
        next
      }
      gsub(/[[:space:]]+/, " + ", mods)
      print mods " + " key
    }'
}

# Wrap a value in a Lua long-bracket string, which avoids escaping quotes and
# keeps `$` intact so the command is expanded by the shell at execution time.
hypr_lua_string() {
  printf '[==[%s]==]' "$1"
}

# hypr_bind <legacy-key-spec> <command> [flag-letters]
# `flags` is the legacy bind suffix, e.g. "ni" for bindni.
hypr_bind() {
  local key="$1" cmd="$2" flags="${3:-}"
  if hypr_uses_lua; then
    local lua_flags=""
    case "$flags" in
      ni) lua_flags=", { non_consuming = true, ignore_mods = true }" ;;
      "") ;;
      *) echo "[hyprmcsr] Unsupported bind flags '$flags' for Hyprland Lua IPC" >&2; return 1 ;;
    esac
    hypr_eval "hl.bind($(hypr_lua_string "$(hypr_lua_key "$key")"), hl.dsp.exec_cmd($(hypr_lua_string "$cmd"))$lua_flags)"
  else
    hyprctl -q keyword "bind$flags" "$key,exec,$cmd"
  fi
}

hypr_unbind() {
  local key="$1"
  if hypr_uses_lua; then
    hypr_eval "hl.unbind($(hypr_lua_string "$(hypr_lua_key "$key")"))"
  else
    hyprctl -q keyword unbind "$key"
  fi
}

hypr_set_sensitivity() {
  local value="$1"
  if hypr_uses_lua; then
    hypr_eval "hl.config({ input = { sensitivity = $value } })"
  else
    # '--' keeps negative values from being parsed as hyprctl options.
    hyprctl -q -- keyword input:sensitivity "$value"
  fi
}

hypr_focus_window() {
  local address="$1"
  if hypr_uses_lua; then
    hypr_eval "hl.dispatch(hl.dsp.focus({ window = \"address:$address\" }))"
  else
    hyprctl -q dispatch focuswindow "address:$address"
  fi
}

hypr_resize_window() {
  local address="$1" width="$2" height="$3"
  if hypr_uses_lua; then
    hypr_eval "hl.dispatch(hl.dsp.window.resize({ x = $width, y = $height, window = \"address:$address\" }))"
  else
    hyprctl -q dispatch resizewindowpixel "exact $width $height,address:$address"
  fi
}

hypr_center_window() {
  local address="$1"
  if hypr_uses_lua; then
    hypr_eval "hl.dispatch(hl.dsp.window.center({ window = \"address:$address\" }))"
  else
    hyprctl -q dispatch centerwindow
  fi
}

hypr_set_floating() {
  local address="$1"
  if hypr_uses_lua; then
    hypr_eval "hl.dispatch(hl.dsp.window.float({ action = \"set\", window = \"address:$address\" }))"
  else
    hyprctl -q dispatch setfloating "address:$address"
  fi
}

hypr_set_window_prop() {
  local address="$1" prop="$2" value="$3"
  if hypr_uses_lua; then
    hypr_eval "hl.dispatch(hl.dsp.window.set_prop({ prop = \"$prop\", value = \"$value\", window = \"address:$address\" }))"
  else
    hyprctl -q dispatch setprop "address:$address" "$prop" "$value"
  fi
}

hypr_move_cursor() {
  local x="$1" y="$2"
  if hypr_uses_lua; then
    hypr_eval "hl.dispatch(hl.dsp.cursor.move({ x = $x, y = $y }))"
  else
    hyprctl -q dispatch movecursor "$x" "$y"
  fi
}
