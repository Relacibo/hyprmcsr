# Changelog

## [0.7.0]

### Changes in `*.profile.json`

#### PrismLauncher Configuration Rename
The PrismLauncher wrapper command configuration structure has been renamed for clarity:

**Old configuration (deprecated):**
```json
"minecraft": {
  "prismLauncher": {
    "wrapperCommand": {
      "autoInsert": true,
      "innerCommand": "obs-gamecapture"
    }
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
    ...
  }
}
```

**Migration:**
- Rename `minecraft.prismLauncher.wrapperCommand` → `minecraft.prismLauncher.autoReplaceWrapperCommand`
- Rename `autoInsert` → `enabled`

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
The state observation configuration has been renamed:

**Old configuration (deprecated):**
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
- State observer timeout reduced from 20s to 5s
- Better null/empty string handling in jq window detection filters

### Fixed
- Window detection now correctly handles both `null` and empty string checks in jq filters
- PID detection using `sort -n` for proper numerical sorting
- Fixed waiting for state file, if it doesn't exist at start
