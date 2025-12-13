#!/bin/bash

# This script updates the PrismLauncher instance.cfg file robustly and idempotently.
# It ensures the [General] section contains the following fields, alphabetically sorted:
#   PostExitCommand= (ensure-init)
#   PreLaunchCommand= (ensure-init)
#   UseCustomCommands=true (override)
#   WrapperCommand=... (override)
# The [UI] section can be handled similarly if needed.

instance_config="$1"
wrapper_cmd="$2"

# Prepare fields for [General] (alphabetical order)
fields=(
  "OverrideCommands:override:true"
  "PostExitCommand:ensure-init:"
  "PreLaunchCommand:ensure-init:"
  "UseCustomCommands:override:true"
  "WrapperCommand:override:$wrapper_cmd"
)

# Build comma-separated strings for awk
field_names=""
field_modes=""
field_values=""
nfields=${#fields[@]}
for i in "${!fields[@]}"; do
  IFS=":" read -r f m v <<< "${fields[$i]}"
  field_names+="$f,"
  field_modes+="$m,"
  field_values+="$v,"
done
field_names="${field_names%,}"
field_modes="${field_modes%,}"
field_values="${field_values%,}"

# Update [General] section in-place
# Use mktemp for the temporary file for safety and atomicity

tmpfile=$(mktemp)
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
      while (i <= nfields) {
        if (modes[i]=="override") print fields[i]"="values[i];
        else if (modes[i]=="ensure-init") print fields[i]"=";
        i++;
      }
    }
    in_section=0; print; next
  }
  in_section {
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

# For [UI] section, add similar logic if needed.
