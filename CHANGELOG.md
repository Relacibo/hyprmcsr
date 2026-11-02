# Changelog

## [Unreleased]

### Added
- Hermes support: observe `hermes/state.json` when a Hermes jar is installed, with automatic fallback to the legacy State Output file (`wpstateout.txt`). The state source is selected from the mods folder instead of racing the two persistent files.
- Center the cursor when a screen opens from gameplay (pause menu, inventory) and for the SeedQueue wall.

### Changed
- The state machine now matches loading screens by class (including `DownloadingTerrainScreen`/`class_434`), re-enables binds in-world as a safety net, and only centers the cursor on real gameplay-to-screen transitions.

### Fixed
- Hyprland 0.57 compatibility: use the Lua IPC (`hl.bind`, `hl.unbind`, `hl.config`, `hl.dsp.*`) when the compositor reports `configProvider: lua`, while keeping the legacy `hyprctl keyword`/string-dispatcher path for older versions
- Custom binds: fixed `realname` typo, accept a single command or an array, and stop quoting command JSON into the Hyprland bind
- State observer: use Bash (the script used Bash-only syntax), wait indefinitely for the instance, and re-arm the file watch after atomic replacements
- `hyprmcsr --help` now exits successfully; unknown commands report a proper error
- `hyprmcsr setup` writes `minecraft.prismLauncher.prismPrefix` instead of the deprecated field
- JAR downloads: fail on HTTP errors, verify the ZIP header, download atomically, and serialize concurrent downloads
- Restore the original mouse sensitivity on `hyprmcsr destroy`
- Wait for PrismLauncher to exit before rewriting its wrapper command
- Fix lexical sorting for PID/sink-input diffing in `instance_wrapper.sh`
- `check-dependencies` no longer requires `inotifywait`/native PrismLauncher when the profile disables or does not use them
- Validate profile names to prevent path traversal
- Documentation fixes (custom bind format, JAR download root, dependency list, missing doc links)

## [0.9.1]

### Changed
- Session state now honors `$XDG_RUNTIME_DIR` (with `/tmp` fallback) instead of using a fixed path.

## [0.9.0]

### Added
- JARs are stored in the XDG data directory (`$XDG_DATA_HOME/hyprmcsr/downloads`), with automatic migration from the legacy `download/jar` directory.
- Kanata documentation replaces the old Input Remapper guide; the example profile was updated accordingly.

### Changed
- `hyprmcsr destroy` runs `onDestroy` hooks to completion before clearing transient state.
- `onStart`/`onDestroy` commands run detached via `setsid` with `bash -l`; failures are logged.
- `requireSudo` fails early when authentication fails and stops the session when the sudo ticket expires.
- Wrapper detection only reads the first `WrapperCommand=` line of an instance config.

### Fixed
- Race between `onDestroy` hooks and state cleanup in `destroy.sh`.
- Duplicate and inconsistent `requireSudo` documentation.
- `instance_cfg_util.sh` no longer duplicates fields when updating an instance config.

## [0.8.6]

### Changed
- **Hyprland 0.55 compatibility**: `setprop` calls use the new property names (`no_anim`, `rounding`) and `centerwindow` no longer takes an `address:` argument.

## [0.8.5]

### Fixed
- Preserve `window_address` across `hyprmcsr destroy` so a still-running Minecraft window can be reattached on the next start.

## [0.8.4]

- Maintenance release (version bump only).

## [0.8.3]

### Changed
- `hyprmcsr setup` asks whether to set up audio splitting instead of always starting it.
- `setup-audio-splitter` offers to restart PipeWire after applying changes.

## [0.8.2]

### Changed
- Cursor centering caches monitor centers and computes the center on demand when the cache is missing.
- `toggle_mode` resolves the monitor ID for every mode and tracks the last monitor.

### Fixed
- `destroy.sh` clears the state directory instead of leaving stale files behind.
- Assorted logging and cleanup fixes.

## [0.8.1]

### Added
- Boat Eye OBS overlay and scene creation instructions.

### Changed
- Documentation examples use `hyprmcsr setup` instead of the old `init` command.
- `run-jar` accepts case-insensitive JAR names and lists removed old versions.

### Fixed
- Case-sensitive JAR lookup.

## [0.8.0]

### Added
- **Flatpak PrismLauncher support**: Full support for PrismLauncher installed via Flatpak
  - New `minecraft.prismLauncher.flatpak` boolean setting to indicate a Flatpak installation
  - Automatic data directory detection (`~/.var/app/org.prismlauncher.PrismLauncher/data/PrismLauncher`)
  - Automatic launch command selection (`flatpak run org.prismlauncher.PrismLauncher`)
  - `hyprmcsr setup` asks whether PrismLauncher is installed via Flatpak
- **New prismPrefix priority system**: `minecraft.prismLauncher.prismPrefix` → Flatpak detection → deprecated `minecraft.prismPrefix` → default

### Changed
- **Renamed command**: `hyprmcsr init` → `hyprmcsr setup` (better describes interactive configuration)

### Deprecated
- `minecraft.prismPrefix` is deprecated in favor of `minecraft.prismLauncher.prismPrefix` and `minecraft.prismLauncher.flatpak`

## [0.7.4]

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

### Fixed
- Expanded the `hyprmcsr --help` examples for `setup-audio-splitter`.

## [0.7.2]

### Added
- `hyprmcsr --help` menu.

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
