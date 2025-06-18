#!/bin/bash
# hyprmcsr: run_conditional_command.sh (moved to util)
# Usage: run_conditional_command.sh '<json_or_string>'
# If JSON: { "exec": "...", "if": "..." }
# If string: just execute

set -e

INPUT="$1"

# Check if input is a JSON object
if [[ "$INPUT" =~ ^\{.*\}$ ]]; then
  exec_cmd=$(echo "$INPUT" | jq -r '.exec // empty')
  if_cond=$(echo "$INPUT" | jq -r '.if // empty')
  if [ -n "$exec_cmd" ]; then
    if [ -n "$if_cond" ]; then
      if bash -c "$if_cond"; then
        bash -c "$exec_cmd" &
      fi
    else
      bash -c "$exec_cmd" &
    fi
  fi
else
  # Plain string
  [ -z "$INPUT" ] && exit 0
  bash -c "$INPUT" &
fi
