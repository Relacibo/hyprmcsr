# Keybinds and Modes

hyprmcsr manages all important keybinds for you:

- **Mode switching:** Change window size, sensitivity, and more with a single keypress.
- **Custom binds:** Define your own keybinds for scripts, OBS actions, etc.
- **Toggle binds:** Quickly enable/disable custom binds.

All binds are defined in your profile config under the `binds` section.

**Examples:**

```json
{
  "binds": {
    "toggleBinds": ",HOME",
    "modeSwitch": {
      "normal": ",N",
      "tall": ",H",
    },
    "custom": {
      "obs-hide": ",F1",
      "obs-show": ",F2"
    }
  },
  "onToggleBinds": [
    "notify-send \"Binds toggled: $BINDS_ENABLED\""
  ],
  "modeSwitch": {
    "default": {
      "size": "fullscreen",
      "onEnter": [
        "notify-send Entering $NEXT_MODE"
      ],
      "onExit": [
        "notify-send Leaving $PREVIOUS_MODE"
      ]
    },
    "modes": {
      "normal": {},
      "tall": {
        "size": "350x750",
        "onEnter": [
          "notify-send \"Tall mode active\""
        ]
      }
    }
  }
}
```

- `toggleBinds`: Key to enable/disable all custom binds.
- `modeSwitch`: Keys to switch between window modes (e.g. tall, boat-eye).
- `custom`: Your own keybinds mapped to commands or scripts.
- `onToggleBinds`: Commands/scripts that run whenever binds are toggled (the variable `$BINDS_ENABLED` is set to `1` or `0`).
- `onEnter`/`onExit`: Commands/scripts that run when entering or leaving a mode (can be set per mode or as default).
- The values in `default` inside `modeSwitch` are the default values for every mode and are always used unless explicitly overridden in the respective mode.
- There is also the `normal` mode, which is always switched to if you press the bind for another mode a second time.
- The name of a mode can be chosen freely, but must match the respective bind key in `modeSwitch`.
- `size`: Can be set to a specific resolution (e.g. `"1920x1080"` or `"350x750"`) or to `"fullscreen"` to automatically use the full monitor size (taking scale into account).
- **The syntax for binds is the same as in Hyprland.** See the [Hyprland Wiki on binds](https://wiki.hyprland.org/Configuring/Binds/) for details.

**Tip:**  
You can use environment variables like `$WINDOW_ADDRESS`, `$SCRIPT_DIR`, `$PROFILE`, `$HYPRMCSR_PROFILE` etc. in your custom commands.
See e.g.: https://github.com/Relacibo/hyprmcsr/blob/36f358b2f96c377e21fb20c3e78f1002e477d6d8/scripts/toggle_mode.sh#L42
