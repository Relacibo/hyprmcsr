#!/bin/bash
# hyprmcsr: run_conditional_command.sh (moved to util)
# Usage: run_conditional_command.sh '<json_or_string>'
# If JSON: { "exec": "...", "if": "..." }
# If string: just execute

set -e

INPUT="$1"

# Ensure all relevant environment variables are exported for child processes
export HYPRMCSR_PROFILE
export PROFILE
export HYPRMCSR_BIN
export STATE_DIR
export SCRIPT_DIR
export PRISM_PREFIX
export MINECRAFT_ROOT
export PRISM_INSTANCE_ID

# Check if input is a JSON object (idiomatisch mit jq)
if echo "$INPUT" | jq -e 'type == "object"' >/dev/null 2>&1; then
  exec_cmd=$(echo "$INPUT" | jq -r '.exec // empty')
  if_cond=$(echo "$INPUT" | jq -r '.if // empty')
  if [ -n "$exec_cmd" ]; then
    if [ -n "$if_cond" ]; then
      if bash -c "$if_cond"; then
        eval "$exec_cmd" &
      fi
    else
      eval "$exec_cmd" &
    fi
  fi
else
  # Prüfe, ob der Input ein gültiger JSON-String ist und extrahiere ggf. den Wert
  plain_cmd=$(echo "$INPUT" | jq -r 'if type=="string" then . else empty end' 2>/dev/null)
  if [ -n "$plain_cmd" ]; then
    eval "$plain_cmd" &
  else
    # Fallback: führe den Input direkt aus, falls kein valider JSON-String
    [ -z "$INPUT" ] && exit 0
    eval $INPUT &
  fi
fi
