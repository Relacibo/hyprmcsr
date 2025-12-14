#!/bin/bash
# hyprmcsr: run_conditional_command.sh (moved to util)
# Usage: run_conditional_command.sh '<json_or_string>' [log_file]
# If JSON: { "exec": "...", "if": "..." }
# If string: just execute

set -e

INPUT="$1"
LOG_FILE="${2:-}"

# Export all relevant environment variables for child processes
UTIL_DIR=$(dirname "${BASH_SOURCE[0]}")
SCRIPT_DIR="${SCRIPT_DIR:-$(realpath "$UTIL_DIR/../scripts")}"
source "$UTIL_DIR/export_env.sh"

# Setup logging redirection
if [ -n "$LOG_FILE" ]; then
  mkdir -p "$(dirname "$LOG_FILE")"
  exec >> "$LOG_FILE" 2>&1
fi

# Check if input is a JSON object (idiomatic with jq)
if echo "$INPUT" | jq -e 'type == "object"' >/dev/null 2>&1; then
  exec_cmd=$(echo "$INPUT" | jq -r '.exec // empty')
  if_cond=$(echo "$INPUT" | jq -r '.if // empty')
  if [ -n "$exec_cmd" ]; then
    if [ -n "$if_cond" ]; then
      if bash -c "$if_cond"; then
        eval "$exec_cmd" || echo "[hyprmcsr] Command failed: $exec_cmd" >&2 &
      fi
    else
      eval "$exec_cmd" || echo "[hyprmcsr] Command failed: $exec_cmd" >&2 &
    fi
  fi
else
  # Check if the input is a valid JSON string and extract the value if possible
  plain_cmd=$(echo "$INPUT" | jq -r 'if type=="string" then . else empty end' 2>/dev/null)
  if [ -n "$plain_cmd" ]; then
    eval "$plain_cmd" || echo "[hyprmcsr] Command failed: $plain_cmd" >&2 &
  else
    # Fallback: execute the input directly if it is not a valid JSON string
    [ -z "$INPUT" ] && exit 0
    eval $INPUT || echo "[hyprmcsr] Command failed: $INPUT" >&2 &
  fi
fi
