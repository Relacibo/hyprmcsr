# Configuration

hyprmcsr uses two types of configuration files, that are automatically created from example files when running `hyprmcsr run` for the first time:

## JAR Repositories: `repositories.json`

- Located in `~/.config/hyprmcsr/repositories.json`
- Contains JAR download sources (GitHub repositories)
- Format: Object with `jar` key mapping JAR names to GitHub repositories
- JARs are downloaded automatically when using `hyprmcsr run-jar`

Example structure:
```json
{
  "jar": {
    "modcheck": "tildejustin/modcheck",
    "ninjabrain-bot": "Ninjabrain1/Ninjabrain-Bot"
  }
}
```

See [example.repositories.json](../example.repositories.json) for a full example.

## Profile config: `<profile>.profile.json`

- Located in `~/.config/hyprmcsr/<profile>.profile.json` (e.g. `default.profile.json`)
- Contains all profile-specific settings (Minecraft instance, binds, modes, etc.)

See [example.default.profile.json](../example.default.profile.json) for a full example of a profile config.

### Key fields

- **onStart**: Array of shell commands/scripts to run in the background when starting (e.g. starting helper tools, OBS, input-remapper, etc.). See [Command Syntax](#command-syntax-string-or-object)
- **onDestroy**: Array of shell commands/scripts to run in the background when stopping (e.g. cleanup, notifications, killing helper tools, stopping input-remapper). See [Command Syntax](#command-syntax-string-or-object)
- **onToggleBinds**: Array of shell commands/scripts to run whenever binds are toggled (e.g. notifications, custom actions).  
  The environment variable `$BINDS_ENABLED` is set to `1` (enabled) or `0` (disabled). See [Command Syntax](#command-syntax-string-or-object)
- **binds.toggleBinds**: Key combination to toggle binds.
- **binds.modeSwitch**: Key combinations for switching between window modes.
- **binds.custom**:  
  Define your own keybinds and associated commands here.  
  The commands will be executed with the environment variables `$HYPRMCSR`, `$WINDOW_ADDRESS`, `$SCRIPT_DIR`, `$PROFILE`, `$HYPRMCSR_PROFILE`, `$PRISM_INSTANCE_ID`, and `$MINECRAFT_ROOT` set. 
- **modeSwitch.default**: Default window size, sensitivity, and optional `onEnter`/`onExit` arrays for commands to run when entering or exiting a mode. See [Command Syntax](#command-syntax-string-or-object)
- **modeSwitch.modes**: Per-mode overrides for size, sensitivity, and `onEnter`/`onExit` commands. See [Command Syntax](#command-syntax-string-or-object)
- **minecraft.prismPrefix**: (Optional) Path to your PrismLauncher data directory. Default: `~/.local/share/PrismLauncher`
- **minecraft.windowClassRegex**:  
  (Optional) Regular expression to detect the Minecraft window by its window class.
- **minecraft.windowTitleRegex**:  
  (Optional) Regular expression to detect the Minecraft window by its window title.
  > **Note:**  
  > Both fields are optional and equivalent.
  >
  > - If **neither** is set, any window is accepted.
  > - If **one** is set, it must match.
  > - If **both** are set, both must match.  
  >   You can check the values with `hyprctl clients -j`.
- **minecraft.observeState.enabled**: Enable or disable State Outputs `wpstateout.txt` observation.
- **minecraft.onStart**: Array of shell commands/scripts to run after Minecraft has started (executed by `instance_wrapper.sh`). See [Command Syntax](#command-syntax-string-or-object)
- **downloadRoot**: (Optional) Custom download root for JARs. If not set, defaults to `<repo>/download`.
- **autoDestroyOnExit**: If true, runs cleanup automatically when the main script exits.
- **requireSudo**: If true, you will be prompted for sudo at start and it will be kept alive for all commands in `onStart`/`onDestroy` (useful for input-remapper or other tools needing root).
- **minecraft.prismLauncher**:  
  Configure PrismLauncher wrapper command, instance ID, and automatic launching.  
  
  **Example (with wrapper and auto-launch):**
  ```json
  "minecraft": {
    ...
    "prismLauncher": {
      "wrapperCommand": {
        "autoInsert": true,
        "innerCommand": "obs-gamecapture"
      },
      "instanceId": "1.16.1",
      "autoLaunch": true
    }
  }
  ```
  
  **Example (only auto-launch, no wrapper):**
  ```json
  "minecraft": {
    ...
    "prismLauncher": {
      "instanceId": "1.16.1",
      "autoLaunch": true
    }
  }
  ```
  
  **Example (only wrapper without innerCommand):**
  ```json
  "minecraft": {
    ...
    "prismLauncher": {
      "wrapperCommand": {
        "autoInsert": true
      },
      "instanceId": "1.16.1"
    }
  }
  ```
  
  **Example (dynamic instance ID):**
  ```json
  "minecraft": {
    ...
    "prismLauncher": {
      "wrapperCommand": {
        "autoInsert": true,
        "innerCommand": "obs-gamecapture"
      },
      "instanceIdScript": "echo $PROFILE",
      "autoLaunch": true
    }
  }
  ```
  
  **Fields:**
  - **prismLauncher.wrapperCommand**: (Optional) Object to configure the wrapper command.
    - **wrapperCommand.autoInsert**: (boolean) When `true`, automatically configures the wrapper command in the PrismLauncher instance configuration file.
    - **wrapperCommand.innerCommand**: (Optional, string) The inner wrapper command to use (e.g., `"obs-gamecapture"`). If omitted, only the hyprmcsr instance wrapper (`instance_wrapper.sh`) is used without an inner command.
  - **prismLauncher.instanceId**: (Optional) Static instance ID to configure (e.g., `"1.16.1"`). See `~/.local/share/PrismLauncher/instances/` for available instances.
  - **prismLauncher.instanceIdScript**: (Optional) Shell command/script to dynamically determine the instance ID. The script's output will be used as the instance ID. If both `instanceId` and `instanceIdScript` are set, `instanceIdScript` takes precedence.  
    
    The script has access to the following environment variables:
    - `$PROFILE` - Current profile name
    - `$HYPRMCSR_PROFILE` - Current hyprmcsr profile
    - `$SCRIPT_DIR` - Path to the hyprmcsr scripts directory
    - `$STATE_DIR` - Path to the hyprmcsr state directory
    - `$PRISM_PREFIX` - Path to PrismLauncher data directory
    
    Examples: 
    - `"echo $PROFILE"` - Use the current profile name as instance ID
    - `"jq -r '.instances[$PROFILE]' ~/.config/my-instances.json"` - Look up instance ID from a JSON file
    - `"cat $STATE_DIR/current-instance.txt"` - Read instance ID from a state file
  - **prismLauncher.autoLaunch**: (Optional, boolean, default: `false`) When `true`, automatically launches Minecraft with `prismlauncher -l <instanceId>` when starting hyprmcsr. Requires `instanceId` or `instanceIdScript` to be set.
  
  > **Note:** The entire `prismLauncher` section is optional. If you don't need any of these features, you can omit it completely.

---

**Tip:**  
You can use variables like `$HYPRMCSR`, `$SCRIPT_DIR`, `$PROFILE`, `$HYPRMCSR_PROFILE`, `$PREVIOUS_MODE`, `$NEXT_MODE`, `$WINDOW_ADDRESS`, `$PRISM_INSTANCE_ID`, `$MINECRAFT_ROOT`, and `$BINDS_ENABLED` in your shell commands in `onStart`, `onDestroy`, `onEnter`, `onExit`, `onToggleBinds`, `minecraft.onStart`, and custom binds.

## Command Syntax: String or Object

All command fields (e.g. `onStart`, `onDestroy`, `onToggleBinds`, `modeSwitch.*.onEnter`, `modeSwitch.*.onExit`) support:

- **String:** always executed
- **Object:**
  - `exec`: command
  - `if`: (optional) bash condition, only executed if true

**Example:**
```json
"onStart": [
  "flatpak run obs",
  { "exec": "do-special", "if": "[ \"$PROFILE\" = \"special\" ]" }
]
```

## PrismLauncher command and data directory

- **Native PrismLauncher:**
  - Command: `prismlauncher -l "<instance id>"`
  - Data directory (`prismPrefix`): `~/.local/share/PrismLauncher`

> **Note:**
> Flatpak is not recommended due to file access and integration issues. For Flatpak-specific instructions and limitations, see [Flatpak Setup](./030-flatpak.md).
