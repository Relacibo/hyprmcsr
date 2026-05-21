#!/bin/bash
# hyprmcsr: run_conditional_command.sh (moved to util)
# Usage: run_conditional_command.sh '<json_or_string>' [log_file]
# If JSON: { "exec": "...", "if": "..." }
# If string: just execute

set -e

INPUT="$1"
LOG_FILE="${2:-}"
RUN_IN_BACKGROUND="${HYPRMCSR_RUN_CONDITIONAL_IN_BACKGROUND:-1}"

# Export all relevant environment variables for child processes
UTIL_DIR=$(dirname "${BASH_SOURCE[0]}")
SCRIPT_DIR="${SCRIPT_DIR:-$(realpath "$UTIL_DIR/../scripts")}"
source "$UTIL_DIR/export_env.sh"

# Setup logging redirection
if [ -n "$LOG_FILE" ]; then
  mkdir -p "$(dirname "$LOG_FILE")"
  exec >> "$LOG_FILE" 2>&1
fi

run_exec_command() {
  local cmd="$1"
  if [ "$RUN_IN_BACKGROUND" = "0" ]; then
    bash -lc "$cmd" || echo "[hyprmcsr] Command failed: $cmd" >&2
  else
    # run in background: Use setsid for decoupling, errors go to stderr if LOG_FILE is not defined
    if [ -n "$LOG_FILE" ]; then
      setsid bash -lc "$cmd" &
    else
      setsid bash -lc "$cmd" >/dev/null 2>&1 &
    fi
  fi
}

# 1. extract command (object -> string -> raw fallback)
EXEC_CMD=$(echo "$INPUT" | jq -e -r '
  if type == "object" then .exec 
  elif type == "string" then . 
  else empty end' 2>/dev/null) || EXEC_CMD="$INPUT"

# Falls Input {} war oder komplett leer ist
[ -z "$EXEC_CMD" ] || [ "$EXEC_CMD" = "null" ] && exit 0

# 2. Extract condition script (Ohne -e, damit leere Werte nicht crashen)
IF_COND=$(echo "$INPUT" | jq -r 'if type == "object" then .if // "true" else "true" end' 2>/dev/null || echo "true")

# Falls im JSON ein leeres "if": "" stand, ebenfalls auf "true" setzen
[ -z "$IF_COND" ] || [ "$IF_COND" = "null" ] && IF_COND="true"

# 3. Execute
if bash -c "$IF_COND"; then
  run_exec_command "$EXEC_CMD"
fi