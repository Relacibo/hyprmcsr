#!/bin/bash

export SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")
CONFIG_ROOT="${XDG_CONFIG_HOME:-$HOME/.config}/hyprmcsr"
REPOSITORIES_FILE="$CONFIG_ROOT/repositories.json"
EXAMPLE_REPOSITORIES="$SCRIPT_DIR/../example.repositories.json"
EXAMPLE_PROFILE="$SCRIPT_DIR/../example.default.profile.json"
TEMPLATE_PROFILE="$SCRIPT_DIR/../templates/default.profile.json"

# Show help
show_help() {
  cat << 'EOF'
Usage: hyprmcsr init [profile] [options]

Create a new hyprmcsr profile interactively.

Arguments:
  profile                     Name of the profile to create (default: 'default')
                              Can also be set via HYPRMCSR_PROFILE environment variable

Options:
  --base-profile <name>       Use an existing profile as template
  --help                      Show this help message

Examples:
  hyprmcsr init                         # Create default.profile.json
  hyprmcsr init ranked                  # Create ranked.profile.json
  hyprmcsr init ranked --base-profile default
                                        # Create ranked.profile.json based on default

The script will interactively prompt for:
  - State Output File observation (wpstateout.txt)
  - PrismLauncher instance ID
  - Auto-launch Minecraft on start
  - Wrapper command injection
  - PrismLauncher data directory (optional, auto-detected by default)
  - Audio splitter setup (optional)

EOF
  exit 0
}

# Parse arguments for flags
BASE_PROFILE=""
while [[ "$1" =~ ^-- ]]; do
  case "$1" in
    --base-profile)
      shift
      BASE_PROFILE="$1"
      shift
      ;;
    --help)
      show_help
      ;;
    *)
      echo "Unknown option: $1"
      echo "Use --help for usage information"
      exit 1
      ;;
  esac
done

mkdir -p "$CONFIG_ROOT"

# Copy repositories.json if not exists
if [ ! -f "$REPOSITORIES_FILE" ]; then
  cp "$EXAMPLE_REPOSITORIES" "$REPOSITORIES_FILE"
  echo "Created $REPOSITORIES_FILE"
else
  echo "File already exists: $REPOSITORIES_FILE"
fi

echo ""
echo "=== Interactive Profile Creation ==="
echo ""

# Run dependency check first
echo "Checking dependencies..."
if "$SCRIPT_DIR/check_dependencies.sh"; then
  echo ""
else
  echo ""
  read -p "Some dependencies are missing. Continue anyway? [y/N]: " continue_anyway
  if [[ ! "$continue_anyway" =~ ^[Yy] ]]; then
    echo "Aborting profile creation."
    exit 1
  fi
  echo ""
fi

# Prompt for profile name (use HYPRMCSR_PROFILE env var if set)
if [ -n "$HYPRMCSR_PROFILE" ]; then
  PROFILE_NAME="$HYPRMCSR_PROFILE"
  echo "Creating profile: $PROFILE_NAME"
else
  read -p "Name of the hyprmcsr profile? (default: default): " PROFILE_NAME
  PROFILE_NAME="${PROFILE_NAME:-default}"
fi
PROFILE_CONFIG_FILE="$CONFIG_ROOT/${PROFILE_NAME}.profile.json"

# Check if profile already exists
if [ -f "$PROFILE_CONFIG_FILE" ]; then
  echo "Profile '$PROFILE_NAME' already exists."
  read -p "Do you want to edit it? [y/N]: " edit_existing
  
  if [[ ! "$edit_existing" =~ ^[Yy] ]]; then
    echo "Aborting. Use a different profile name or edit manually."
    exit 0
  fi
  
  echo "Editing existing profile: $PROFILE_NAME"
  EDITING_EXISTING=true
else
  EDITING_EXISTING=false
fi

# Check if jq is available
if ! command -v jq >/dev/null; then
  echo "jq is required but not installed. Falling back to copying template file."
  cp "$TEMPLATE_PROFILE" "$PROFILE_CONFIG_FILE"
  echo "Created $PROFILE_CONFIG_FILE"
  echo "Initialization complete. Configuration files are in $CONFIG_ROOT"
  exit 0
fi

# Load template based on --base-profile flag
if [ -n "$BASE_PROFILE" ]; then
  BASE_PROFILE_FILE="$CONFIG_ROOT/${BASE_PROFILE}.profile.json"
  if [ -f "$BASE_PROFILE_FILE" ]; then
    echo "Using $BASE_PROFILE.profile.json as template"
    TEMPLATE_FILE="$BASE_PROFILE_FILE"
  else
    echo "Base profile '$BASE_PROFILE' not found at $BASE_PROFILE_FILE"
    exit 1
  fi
elif [ "$EDITING_EXISTING" = true ]; then
  # When editing, use the existing profile as template
  echo "Loading existing profile values..."
  TEMPLATE_FILE="$PROFILE_CONFIG_FILE"
else
  # Always use template profile as default template
  TEMPLATE_FILE="$TEMPLATE_PROFILE"
fi

# Extract default values always from example file for consistent defaults
DEFAULT_PRISM_PREFIX=$(jq -r '.minecraft.prismPrefix // ""' "$EXAMPLE_PROFILE")
DEFAULT_OBSERVE_STATE=$(jq -r '.minecraft.observeState.enabled // true' "$EXAMPLE_PROFILE")
DEFAULT_INSTANCE_ID=""  # No default from template
DEFAULT_AUTO_LAUNCH=$(jq -r '.minecraft.prismLauncher.autoLaunch // false' "$EXAMPLE_PROFILE")
DEFAULT_WRAPPER_ENABLED=$(jq -r '.minecraft.prismLauncher.autoReplaceWrapperCommand.enabled // false' "$EXAMPLE_PROFILE")
DEFAULT_INNER_COMMAND=""  # No default from template
DEFAULT_REQUIRE_SUDO=$(jq -r '.requireSudo // false' "$EXAMPLE_PROFILE")

# When editing an existing profile, load current values from it
if [ "$EDITING_EXISTING" = true ]; then
  CURRENT_PRISM_PREFIX=$(jq -r '.minecraft.prismPrefix // ""' "$PROFILE_CONFIG_FILE")
  CURRENT_OBSERVE_STATE=$(jq -r '.minecraft.observeState.enabled // true' "$PROFILE_CONFIG_FILE")
  CURRENT_INSTANCE_ID=$(jq -r '.minecraft.prismLauncher.instanceId // ""' "$PROFILE_CONFIG_FILE")
  CURRENT_AUTO_LAUNCH=$(jq -r '.minecraft.prismLauncher.autoLaunch // false' "$PROFILE_CONFIG_FILE")
  CURRENT_WRAPPER_ENABLED=$(jq -r '.minecraft.prismLauncher.autoReplaceWrapperCommand.enabled // false' "$PROFILE_CONFIG_FILE")
  CURRENT_INNER_COMMAND=$(jq -r '.minecraft.prismLauncher.autoReplaceWrapperCommand.innerCommand // ""' "$PROFILE_CONFIG_FILE")
  CURRENT_REQUIRE_SUDO=$(jq -r '.requireSudo // false' "$PROFILE_CONFIG_FILE")
  
  # Use current values as defaults when editing
  [ -n "$CURRENT_PRISM_PREFIX" ] && DEFAULT_PRISM_PREFIX="$CURRENT_PRISM_PREFIX"
  DEFAULT_OBSERVE_STATE="$CURRENT_OBSERVE_STATE"
  [ -n "$CURRENT_INSTANCE_ID" ] && DEFAULT_INSTANCE_ID="$CURRENT_INSTANCE_ID"
  DEFAULT_AUTO_LAUNCH="$CURRENT_AUTO_LAUNCH"
  DEFAULT_WRAPPER_ENABLED="$CURRENT_WRAPPER_ENABLED"
  [ -n "$CURRENT_INNER_COMMAND" ] && DEFAULT_INNER_COMMAND="$CURRENT_INNER_COMMAND"
  DEFAULT_REQUIRE_SUDO="$CURRENT_REQUIRE_SUDO"
fi

# Convert JSON booleans to y/n defaults
if [ "$DEFAULT_OBSERVE_STATE" = "true" ]; then
  observe_default="Y/n"
else
  observe_default="y/N"
fi

if [ "$DEFAULT_AUTO_LAUNCH" = "true" ]; then
  auto_launch_default="Y/n"
else
  auto_launch_default="y/N"
fi

if [ "$DEFAULT_WRAPPER_ENABLED" = "true" ]; then
  wrapper_default="Y/n"
else
  wrapper_default="y/N"
fi

if [ "$DEFAULT_REQUIRE_SUDO" = "true" ]; then
  require_sudo_default="Y/n"
else
  require_sudo_default="y/N"
fi

# Set prompt text based on edit mode
if [ "$EDITING_EXISTING" = true ]; then
  DEFAULT_TEXT="previous value"
else
  DEFAULT_TEXT="default"
fi

echo ""

# Prompt for require sudo
read -p "Require sudo privileges on start? ($DEFAULT_TEXT: $([ "$DEFAULT_REQUIRE_SUDO" = "true" ] && echo "yes" || echo "no")) [y/n]: " require_sudo_input
require_sudo_input="${require_sudo_input:-$([ "$DEFAULT_REQUIRE_SUDO" = "true" ] && echo "y" || echo "n")}"
if [[ "$require_sudo_input" =~ ^[Yy] ]]; then
  require_sudo="true"
else
  require_sudo="false"
fi

# Prompt for state observation
read -p "Enable State Output File observation? ($DEFAULT_TEXT: $([ "$DEFAULT_OBSERVE_STATE" = "true" ] && echo "yes" || echo "no")) [y/n]: " observe_state
observe_state="${observe_state:-y}"
if [[ "$observe_state" =~ ^[Yy] ]]; then
  observe_enabled="true"
else
  observe_enabled="false"
fi

# Prompt for PrismLauncher instance
echo ""

# List available instances
PRISM_INSTANCES_DIR="$HOME/.local/share/PrismLauncher/instances"
if [ -d "$PRISM_INSTANCES_DIR" ]; then
  # Get list of instances (directories only, exclude instgroups.json)
  mapfile -t INSTANCES < <(find "$PRISM_INSTANCES_DIR" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort)
  
  if [ ${#INSTANCES[@]} -gt 0 ]; then
    echo "Available PrismLauncher instances:"
    for i in "${!INSTANCES[@]}"; do
      echo "  $((i+1)). ${INSTANCES[$i]}"
    done
    echo ""
    
    if [ -n "$DEFAULT_INSTANCE_ID" ]; then
      # Find index of default instance
      DEFAULT_INDEX=""
      for i in "${!INSTANCES[@]}"; do
        if [ "${INSTANCES[$i]}" = "$DEFAULT_INSTANCE_ID" ]; then
          DEFAULT_INDEX=$((i+1))
          break
        fi
      done
      
      if [ -n "$DEFAULT_INDEX" ]; then
        read -p "Select instance by number [1-${#INSTANCES[@]}] or enter custom ID ($DEFAULT_TEXT: $DEFAULT_INDEX - $DEFAULT_INSTANCE_ID): " instance_input
      else
        read -p "Select instance by number [1-${#INSTANCES[@]}] or enter custom ID ($DEFAULT_TEXT: $DEFAULT_INSTANCE_ID): " instance_input
      fi
    else
      read -p "Select instance by number [1-${#INSTANCES[@]}] or enter custom ID (leave empty to skip): " instance_input
    fi
    
    # Check if input is a number and within range
    if [[ "$instance_input" =~ ^[0-9]+$ ]] && [ "$instance_input" -ge 1 ] && [ "$instance_input" -le ${#INSTANCES[@]} ]; then
      instance_id="${INSTANCES[$((instance_input-1))]}"
    elif [ -z "$instance_input" ] && [ -n "$DEFAULT_INSTANCE_ID" ]; then
      instance_id="$DEFAULT_INSTANCE_ID"
    else
      instance_id="$instance_input"
    fi
  else
    # No instances found, ask for manual input
    if [ -n "$DEFAULT_INSTANCE_ID" ]; then
      read -p "PrismLauncher instance ID ($DEFAULT_TEXT: $DEFAULT_INSTANCE_ID): " instance_id
      instance_id="${instance_id:-$DEFAULT_INSTANCE_ID}"
    else
      read -p "PrismLauncher instance ID (leave empty to skip): " instance_id
    fi
  fi
else
  # Directory doesn't exist, ask for manual input
  if [ -n "$DEFAULT_INSTANCE_ID" ]; then
    read -p "PrismLauncher instance ID ($DEFAULT_TEXT: $DEFAULT_INSTANCE_ID): " instance_id
    instance_id="${instance_id:-$DEFAULT_INSTANCE_ID}"
  else
    read -p "PrismLauncher instance ID (leave empty to skip): " instance_id
  fi
fi

# Prompt for auto-launch
if [ -n "$instance_id" ]; then
  if [ "$DEFAULT_AUTO_LAUNCH" = "true" ]; then
    read -p "Auto-launch Minecraft on start? ($DEFAULT_TEXT: yes) [y/n]: " auto_launch_input
    auto_launch_input="${auto_launch_input:-y}"
  else
    read -p "Auto-launch Minecraft on start? ($DEFAULT_TEXT: no) [y/n]: " auto_launch_input
    auto_launch_input="${auto_launch_input:-n}"
  fi
  
  if [[ "$auto_launch_input" =~ ^[Yy] ]]; then
    auto_launch="true"
  else
    auto_launch="false"
  fi
else
  auto_launch="false"
fi

# Prompt for wrapper command
if [ -n "$instance_id" ]; then
  echo ""
  if [ "$DEFAULT_WRAPPER_ENABLED" = "true" ]; then
    read -p "Enable injecting wrapper command into prism config on start? ($DEFAULT_TEXT: yes) [y/n]: " wrapper_input
    wrapper_input="${wrapper_input:-y}"
  else
    read -p "Enable injecting wrapper command into prism config on start? ($DEFAULT_TEXT: no) [y/n]: " wrapper_input
    wrapper_input="${wrapper_input:-n}"
  fi
  
  if [[ "$wrapper_input" =~ ^[Yy] ]]; then
    wrapper_enabled="true"
    
    # Ask if inner command should be used
    if [ -n "$DEFAULT_INNER_COMMAND" ]; then
      read -p "Use an inner wrapper command? ($DEFAULT_TEXT: yes) [y/n]: " use_inner_input
      use_inner_input="${use_inner_input:-y}"
    else
      read -p "Use an inner wrapper command? ($DEFAULT_TEXT: no) [y/n]: " use_inner_input
      use_inner_input="${use_inner_input:-n}"
    fi
    
    if [[ "$use_inner_input" =~ ^[Yy] ]]; then
      # Ask for the actual command
      if [ -n "$DEFAULT_INNER_COMMAND" ]; then
        read -p "Inner wrapper command ($DEFAULT_TEXT: $DEFAULT_INNER_COMMAND): " inner_command
        inner_command="${inner_command:-$DEFAULT_INNER_COMMAND}"
      else
        read -p "Inner wrapper command: " inner_command
      fi
    else
      inner_command=""
    fi
  else
    wrapper_enabled="false"
    inner_command=""
  fi
else
  wrapper_enabled="false"
  inner_command=""
fi

# Prompt for PrismLauncher prefix (advanced, optional)
echo ""
if [ -n "$DEFAULT_PRISM_PREFIX" ]; then
  read -p "PrismLauncher data directory ($DEFAULT_TEXT: $DEFAULT_PRISM_PREFIX, leave empty for auto-detection): " prism_prefix
  prism_prefix="${prism_prefix:-$DEFAULT_PRISM_PREFIX}"
else
  read -p "PrismLauncher data directory ($DEFAULT_TEXT: auto-detection): " prism_prefix
fi

# Create profile from template
if [ "$EDITING_EXISTING" = false ]; then
  cp "$TEMPLATE_FILE" "$PROFILE_CONFIG_FILE"
fi

# Update requireSudo
jq --argjson sudo "$require_sudo" '.requireSudo = $sudo' "$PROFILE_CONFIG_FILE" > "$PROFILE_CONFIG_FILE.tmp" && mv "$PROFILE_CONFIG_FILE.tmp" "$PROFILE_CONFIG_FILE"

# Update observeState
jq --argjson enabled "$observe_enabled" '.minecraft.observeState.enabled = $enabled' "$PROFILE_CONFIG_FILE" > "$PROFILE_CONFIG_FILE.tmp" && mv "$PROFILE_CONFIG_FILE.tmp" "$PROFILE_CONFIG_FILE"

# Update PrismLauncher settings
if [ -n "$instance_id" ]; then
  jq --arg id "$instance_id" '.minecraft.prismLauncher.instanceId = $id' "$PROFILE_CONFIG_FILE" > "$PROFILE_CONFIG_FILE.tmp" && mv "$PROFILE_CONFIG_FILE.tmp" "$PROFILE_CONFIG_FILE"
  jq --argjson launch "$auto_launch" '.minecraft.prismLauncher.autoLaunch = $launch' "$PROFILE_CONFIG_FILE" > "$PROFILE_CONFIG_FILE.tmp" && mv "$PROFILE_CONFIG_FILE.tmp" "$PROFILE_CONFIG_FILE"
  jq --argjson enabled "$wrapper_enabled" '.minecraft.prismLauncher.autoReplaceWrapperCommand.enabled = $enabled' "$PROFILE_CONFIG_FILE" > "$PROFILE_CONFIG_FILE.tmp" && mv "$PROFILE_CONFIG_FILE.tmp" "$PROFILE_CONFIG_FILE"
  
  # Update inner command if provided
  if [ -n "$inner_command" ]; then
    jq --arg cmd "$inner_command" '.minecraft.prismLauncher.autoReplaceWrapperCommand.innerCommand = $cmd' "$PROFILE_CONFIG_FILE" > "$PROFILE_CONFIG_FILE.tmp" && mv "$PROFILE_CONFIG_FILE.tmp" "$PROFILE_CONFIG_FILE"
  fi
fi

echo ""
if [ "$EDITING_EXISTING" = true ]; then
  echo "Updated $PROFILE_CONFIG_FILE"
else
  echo "Created $PROFILE_CONFIG_FILE"
fi

# Call audio splitter setup script in interactive mode
"$SCRIPT_DIR/setup_audio_splitter.sh"

echo ""
echo "Initialization complete. Configuration files are in $CONFIG_ROOT"
