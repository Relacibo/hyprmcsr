# Changelog

## [Unreleased]

### Added
- **Interactive profile creation**: `hyprmcsr init` now interactively prompts for basic configuration settings
  - Profile name selection
  - Sudo privileges requirement
  - State output file observation
  - PrismLauncher instance selection (with numbered list)
  - Auto-launch and wrapper command configuration
  - Inner wrapper command setup
  - PrismLauncher data directory (optional)
  - Audio splitter setup with monitor sink selection
  - Profile editing support (edit existing profiles)
  - `--base-profile` flag to create new profiles based on existing ones
  - `--help` flag for init command
- **Fullscreen mode size**: Set `"size": "fullscreen"` in `modeSwitch.default` or any mode to automatically use monitor resolution (accounting for Hyprland scale)
- **Dependency checker**: `hyprmcsr check-dependencies` command to verify all required and optional dependencies
- **Minimal profile template**: Clean template at `templates/default.profile.json` with essential configuration only

### Changed
- Default mode size is now `"fullscreen"` instead of `1920x1080`
- `hyprmcsr run` now calls `hyprmcsr init` interactively if profile doesn't exist
- Audio splitter setup now shows current status and suggests appropriate default action
- Init script uses minimal template instead of example profile for cleaner new profiles

### Documentation
- Updated keybinds and modes documentation with fullscreen size option
- Added comprehensive init command documentation
- Updated configuration docs with fullscreen size explanation

## [0.7.3]

### Added
`hyprmcsr --help` menu

## [0.7.1]

### Fix
- Center cursor: Take monitor scale into account

## [0.7.0]

### Changes in `*.profile.json`

#### PrismLauncher Configuration Restructure

**Old configuration (0.6.x):**
```json
"minecraft": {
  "prismWrapperCommand": {
    "autoReplace": true,
    "innerCommand": "obs-gamecapture",
    "prismMinecraftInstanceIds": ["1.16.1"]
  }
}
```

**New configuration:**
```json
"minecraft": {
  "prismLauncher": {
    "autoReplaceWrapperCommand": {
      "enabled": true,
      "innerCommand": "obs-gamecapture"
    },
    "instanceId": "1.16.1"
  }
}
```

**Migration:**
- Rename `minecraft.prismWrapperCommand` → `minecraft.prismLauncher`
- Rename `autoReplace` → `autoReplaceWrapperCommand.enabled`
- Move `innerCommand` into `autoReplaceWrapperCommand` object
- Rename `prismMinecraftInstanceIds` (array) → `instanceId` (string, take first element if you had multiple)

**Additional PrismLauncher Options:**

New optional fields for instance management and auto-launching:

```json
"minecraft": {
  "prismLauncher": {
    "autoReplaceWrapperCommand": {
      "enabled": true,
      "innerCommand": "obs-gamecapture"
    },
    "instanceId": "1.16.1",
    "autoLaunch": true
  }
}
```

Or with dynamic instance ID:

```json
"minecraft": {
  "prismLauncher": {
    "autoReplaceWrapperCommand": {
      "enabled": true
    },
    "instanceIdScript": "echo $PROFILE",
    "autoLaunch": false
  }
}
```

**New fields:**
- `instanceId`: Static instance ID to configure (e.g., `"1.16.1"`)
- `instanceIdScript`: Shell script to dynamically determine instance ID (takes precedence over `instanceId`)
- `autoLaunch`: When `true`, automatically launches Minecraft with the specified instance when running `hyprmcsr run`

**Migration for autoLaunch:**

If you previously had PrismLauncher in your `onStart` commands:

**Old:**
```json
"onStart": [
  "prismlauncher -l 1.16.1",
  "other-command"
]
```

**New:**
```json
"onStart": [
  "other-command"
],
"minecraft": {
  "prismLauncher": {
    "instanceId": "1.16.1",
    "autoLaunch": true
  }
}
```

Remove the `prismlauncher -l <instance-id>` command from `onStart` and use `autoLaunch: true` with `instanceId` instead.

#### ObserveState Configuration Rename

**Old configuration (0.6.x):**
```json
"minecraft": {
  "observeLog": {
    "enabled": true
  }
}
```

**New configuration:**
```json
"minecraft": {
  "observeState": {
    "enabled": true
  }
}
```

**Migration:**
- Rename `minecraft.observeLog` → `minecraft.observeState`

### Added
- Debug output for better visibility of internal operations:
  - Window detection status and found PIDs
  - State file observation with state change logging
  - Wrapper command configuration status
- Command output logging: All commands started via `onStart`, `minecraft.onStart`, and `onDestroy` now log to `~/.cache/hyprmcsr/logs/` instead of stdout
  - `onStart0.log`, `onStart1.log`, etc. for profile start commands
  - `minecraft.onStart0.log`, etc. for Minecraft-specific start commands
  - `onDestroy0.log`, etc. for cleanup commands
  - `prismlauncher.log` for PrismLauncher autolaunch output

### Changed
- PrismLauncher restart behavior: Only prompts to close PrismLauncher if the wrapper command actually needs updating
- Improved window detection with fallback mechanism:
  - First 15 seconds: Search by new Java PIDs matching window regex
  - After 15 seconds: Fallback to regex-only window detection (supports xwayland windows)
  - Total timeout: 20 seconds
- All `hyprctl keyword` commands now use `-q` flag to suppress "ok" output
- State observer timeout reduced from 20s to 10s
- Better null/empty string handling in jq window detection filters

### Fixed
- Window detection now correctly handles both `null` and empty string checks in jq filters
- PID detection using `sort -n` for proper numerical sorting
- Fixed waiting for state file, if it doesn't exist at start
