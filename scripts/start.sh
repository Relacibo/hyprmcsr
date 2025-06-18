#!/bin/bash


# Sets or initializes multiple fields in the [$section] section at the correct alphabetical position (single pass, robust, sorted)
# Fields as an alphabetically sorted array: FIELDS=("Field1:mode:val" "Field2:mode:val" ...)
set_instance_cfg_fields_in_section() {
  local instance_config="$1"
  local section="$2"
  shift 2
  local fields=("$@")

  local tmpfile
  tmpfile=$(mktemp)

  if [ "$section" = "General" ]; then
    # Build comma-separated strings for field names, modes, and values
    local field_names=""
    local field_modes=""
    local field_values=""
    local nfields=${#fields[@]}
    for i in "${!fields[@]}"; do
      IFS=":" read -r f m v <<< "${fields[$i]}"
      field_names+="$f,"
      field_modes+="$m,"
      field_values+="$v,"
    done
    # Remove trailing comma
    field_names="${field_names%,}"
    field_modes="${field_modes%,}"
    field_values="${field_values%,}"
    awk -v nfields="$nfields" \
      -v field_names="$field_names" -v field_modes="$field_modes" -v field_values="$field_values" '
      BEGIN {
        in_section=0; i=1;
        split(field_names, fields, ",");
        split(field_modes, modes, ",");
        split(field_values, values, ",");
      }
      $0 ~ /^\[General\]/ { print; in_section=1; next }
      /^\[/ && $0 !~ /^\[General\]/ {
        if (in_section) {
          # Insert remaining fields at the end of the block
          while (i <= nfields) {
            if (modes[i]=="override") print fields[i]"="values[i];
            else if (modes[i]=="ensure-init") print fields[i]"=";
            i++;
          }
        }
        in_section=0; print; next
      }
      in_section {
        # Extract field name from line
        match($0, /^([^=]+)=/, m)
        curr = m[1]
        while (i <= nfields && fields[i] < curr) {
          if (modes[i]=="override") print fields[i]"="values[i];
          else if (modes[i]=="ensure-init") print fields[i]"=";
          i++;
        }
        if (i <= nfields && fields[i] == curr) {
          if (modes[i]=="override") print fields[i]"="values[i];
          else if (modes[i]=="ensure-init") print $0;
          i++;
          next;
        }
        print; next
      }
      { print }
      END {
        if (in_section) {
          while (i <= nfields) {
            if (modes[i]=="override") print fields[i]"="values[i];
            else if (modes[i]=="ensure-init") print fields[i]"=";
            i++;
          }
        }
      }
    ' "$instance_config" > "$tmpfile" && mv "$tmpfile" "$instance_config"
  else
    # For other sections, handle only one field at a time
    local field mode value
    IFS=":" read -r field mode value <<< "${fields[0]}"
    awk -v section="$section" -v field="$field" -v mode="$mode" -v value="$value" '
      BEGIN { in_section=0 }
      $0 ~ "^\\["section"\\]" {
        print
        in_section=1
        if (mode == "override") {
          print field"="value
        } else if (mode == "ensure-init") {
          print field"="
        }
        next
      }
      /^\[/ && $0 !~ "^\\["section"\\]" { in_section=0 }
      in_section && $0 ~ "^"field"=" { next }
      { print }
    ' "$instance_config" > "$tmpfile" && mv "$tmpfile" "$instance_config"
  fi
}

update_instance_config_section() {
  local instance_config="$1"
  local wrapper_cmd="$2"
  local profile_config_file="$3"

  # Pass fields for [General] in alphabetical order
  local fields=(
    "PostExitCommand:ensure-init:"
    "PreLaunchCommand:ensure-init:"
    "UseCustomCommands:override:true"
    "WrapperCommand:override:$wrapper_cmd"
  )
  set_instance_cfg_fields_in_section "$instance_config" "General" "${fields[@]}"

  # [UI] as before, only two fields
  # set_instance_cfg_fields_in_section "$instance_config" "UI" "WrapperCommand:override:$wrapper_cmd"
  # set_instance_cfg_fields_in_section "$instance_config" "UI" "UseCustomCommands:override:true"
}

SCRIPT_DIR="$(dirname "$(realpath "$0")")"

# General profile logic
# Entfernt: Argumenten-Parsing für PROFILE und HYPRMCSR_PROFILE
# Die Umgebungsvariablen werden direkt verwendet, wie sie gesetzt sind

export HYPRMCSR_PROFILE="${HYPRMCSR_PROFILE:-default}"
export PROFILE="${PROFILE:-default}"
# Source env scripts from util
source "$SCRIPT_DIR/../util/env_core.sh"
source "$SCRIPT_DIR/../util/env_prism.sh"

if ! command -v jq >/dev/null; then
  echo "jq is required!"
  exit 1
fi

# Check for sudo requirement early
REQUIRE_SUDO=$(jq -r '.requireSudo // false' "$PROFILE_CONFIG_FILE")
if [ "$REQUIRE_SUDO" = "true" ]; then
  sudo -v
fi

echo "default" > "$STATE_DIR/window_switcher_state"
echo "$HYPRMCSR_PROFILE" > "$STATE_DIR/profile"

# Set keybinds for mode switches
jq -r '.binds.modeSwitch | to_entries[] | "\(.key) \(.value)"' "$PROFILE_CONFIG_FILE" | while read -r mode key; do
    hyprctl keyword bindni $key,exec,"$HYPRMCSR_BIN -h $HYPRMCSR_PROFILE toggle_mode $mode"
done

toggle_binds_key=$(jq -r '.binds.toggleBinds' "$PROFILE_CONFIG_FILE")
if [ -n "$toggle_binds_key" ] && [ "$toggle_binds_key" != "null" ]; then
  hyprctl keyword bind $toggle_binds_key,exec,"$HYPRMCSR_BIN -h $HYPRMCSR_PROFILE toggle_binds"
fi

# Evaluate prismWrapperCommand
PRISM_WRAPPER_AUTO_REPLACE=$(jq -r '.minecraft.prismWrapperCommand.autoReplace // true' "$PROFILE_CONFIG_FILE")
INNER_WRAPPER_CMD=$(jq -r '.minecraft.prismWrapperCommand.innerCommand // empty' "$PROFILE_CONFIG_FILE")
PRISM_INSTANCE_IDS=$(jq -r '.minecraft.prismWrapperCommand.prismMinecraftInstanceIds[]?' "$PROFILE_CONFIG_FILE")

# Fallback: Use only the outer command if innerCommand is empty/null
if [ "$INNER_WRAPPER_CMD" = "null" ] || [ "$INNER_WRAPPER_CMD" = "empty" ] || [ -z "$INNER_WRAPPER_CMD" ]; then
  WRAPPER_CMD="$HYPRMCSR_BIN -h $HYPRMCSR_PROFILE instance-wrapper"
else
  WRAPPER_CMD="$HYPRMCSR_BIN -h $HYPRMCSR_PROFILE instance-wrapper $INNER_WRAPPER_CMD"
fi

if [ "$PRISM_WRAPPER_AUTO_REPLACE" = "true" ]; then
  if [ -n "$PRISM_INSTANCE_IDS" ]; then
    echo "$PRISM_INSTANCE_IDS" | while IFS= read -r INSTANCE_ID; do
      [ -z "$INSTANCE_ID" ] && continue
      INSTANCE_CONFIG="$PRISM_PREFIX/instances/$INSTANCE_ID/instance.cfg"
      if [ -f "$INSTANCE_CONFIG" ]; then
        # Set WrapperCommand and UseCustomCommands in [General] section only
        if grep -q "^\[General\]" "$INSTANCE_CONFIG"; then
          update_instance_config_section "$INSTANCE_CONFIG" "$WRAPPER_CMD" "$PROFILE_CONFIG_FILE"
        fi
      fi
    done
  fi
fi

# Create custom binds from config.json (with all relevant environment variables)
custom_binds=$(jq -r '.binds.custom // {} | to_entries[] | "\(.key) \(.value|@json)"' "$PROFILE_CONFIG_FILE")
if [ -n "$custom_binds" ]; then
  while IFS= read -r entry; do
    bind=$(echo "$entry" | awk '{print $1}')
    cmds=$(echo "$entry" | cut -d' ' -f2-)
    hyprctl keyword bind "$bind,exec,$HYPRMCSR_BIN -h $HYPRMCSR_PROFILE custom-bind-wrapper '$cmds'"
  done <<< "$custom_binds"
fi

# Run onStart commands from config.json (all in background, with all relevant environment variables)
on_start_cmds=$(jq -c '.onStart[]?' "$PROFILE_CONFIG_FILE")
if [ -n "$on_start_cmds" ]; then
  while IFS= read -r cmd; do
    "$SCRIPT_DIR/../util/run_conditional_command.sh" "$cmd"
  done <<< "$on_start_cmds"
fi

OBSERVE_LOG=$(jq -r '.minecraft.observeLog.enabled // true' "$PROFILE_CONFIG_FILE")
if [ "$OBSERVE_LOG" = "true" ]; then
  (
    export HYPRMCSR_PROFILE PRISM_INSTANCE_ID MINECRAFT_ROOT
    $SCRIPT_DIR/observe_log.sh &
    LOG_MONITOR_PID=$!
  )
fi

# Sudo handling depending on requireSudo
# (leave only the refresh/trap logic here)
auto_destroy=$(jq -r '.autoDestroyOnExit // true' "$PROFILE_CONFIG_FILE")

if [ "$REQUIRE_SUDO" = "true" ]; then
  if [ "$auto_destroy" = "true" ]; then
    while true; do sudo -v; sleep 60; done &
    SUDO_REFRESH_PID=$!
    trap 'kill $SUDO_REFRESH_PID 2>/dev/null; kill $LOG_MONITOR_PID 2>/dev/null; sudo -v; $SCRIPT_DIR/destroy.sh; exit' SIGINT SIGTERM
    echo "Press Ctrl+C to exit. On exit, destroy.sh will be executed automatically."
    sleep infinity
  fi
else
  if [ "$auto_destroy" = "true" ]; then
    trap 'kill $LOG_MONITOR_PID 2>/dev/null; $SCRIPT_DIR/destroy.sh; exit' SIGINT SIGTERM
    echo "Press Ctrl+C to exit. On exit, destroy.sh will be executed automatically."
    sleep infinity
  fi
fi
