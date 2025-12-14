# Changelog

## [Unreleased]

### Breaking Changes - Configuration Updates Required

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
    }
  }
}
```

**Migration:**
- Rename `minecraft.prismLauncher.wrapperCommand` → `minecraft.prismLauncher.autoReplaceWrapperCommand`
- Rename `autoInsert` → `enabled`

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
