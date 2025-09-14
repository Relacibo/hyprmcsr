# Boat Eye

For "Boat Eye", the Minecraft window needs to be stretched vertically, and you also need a separate zoomed-in OBS projection window. You can optionally change your "Cursor Speed" as well.

## OBS Configuration

See [OBS Setup](./013-obs-setup.md) for general instructions.  
Creating the Boat Eye OBS scene:

1. **Create a new scene** in OBS, e.g., "BoatEyeScene".
2. **Add a dedicated Game Capture source** that captures Minecraft to that scene.
3. **Adjust the source:**
   - **Position:** Centered
   - **Size:** Set the bounding box to **half the width and half the height** of your monitor resolution (e.g., 960x540 for 1920x1080).
   - **Alignment:** Centered
4. **Project** this scene to a separate monitor if you like. Alternatively, press `mainMod + V` while hovering over the magnifier scene projection window to set it to floating. Then move or resize the window with `mainMod + LMB/RMB` and dragging.  
Note: this only works if you’ve set it up that way in your `hyprland.conf`. If you are using "V" as a hotkey while playing, change this to something different.

To ensure Boat Eye works correctly, the entire Minecraft window must be captured. The recommended way to achieve this on Linux is by using [obs-vkcapture](https://github.com/nowrep/obs-vkcapture), as it reliably records the full game window, even while it is stretched vertically.

See the [With obs-vkcapture](./013-obs-setup.md#with-obs-vkcapture) section for details on how to set up obs-vkcapture.

## Automatic Overlay Toggle with obs-cli

To show or hide the Boat Eye overlay, you can use [obs-cli](https://github.com/pschmitt/obs-cli).  
Example configuration in your profile (`<profile>.profile.json`):

```json
"boat-eye": {
  "size": "384x16384",
  "sensitivity": "-0.9375",
  "onEnter": [
    "# ~/.local/bin/razer-cli --dpi 100",
    "~/.local/bin/obs-cli item show --scene BoatEyeScene GameCapture"
  ],
  "onExit": [
    "# ~/.local/bin/razer-cli --dpi 1800",
    "~/.local/bin/obs-cli item hide --scene BoatEyeScene GameCapture"
  ]
}
```
- When you switch to Boat Eye mode (using your hotkey), the magnifier scene becomes visible.  
- Once you leave Boat Eye mode, the magnifier scene is hidden again.  
- Adjust paths and scene names as needed for your setup.

## Mouse Sensitivity for Boat Eye

A video explaining the settings:  
[Boat Eye Setup Guide (YouTube) by osh](https://youtu.be/HcrrfsHrR_c?si=cBb7WcvToLk3ukHg)

**To calculate the optimal pointer speed:**  
Use this tool: [Pixel-Perfect-Tools/calc](https://priffin.github.io/Pixel-Perfect-Tools/calc.html)  
Note: The tool uses Windows cursor speed.

### Conversion Table: Windows → Linux

This conversion table isn’t perfectly accurate. The libinput sensitivity values are only approximations, so you’ll likely need to fine-tune them yourself. `-0.96875` feels faster than Cursor Speed `1` on Windows, so you can try `sensitivity = -1` for Boat Eye. The accuracy of Boat Eye itself won’t be affected by sensitivity changes, but it’s still a good idea to get it as close as possible to your usual Windows cursor speed so your muscle memory carries over.

| Windows | xinput   | libinput        |
|---------|----------|-----------------|
| 1       | 0.03125  | ~ -0.96875 |
| 2       | 0.0625   | ~ -0.9375  |
| 3       | 0.125    | ~ -0.875   |
| 4       | 0.25     | ~ -0.75    |
| 5       | 0.375    | ~ -0.625   |
| 6       | 0.5      | ~ -0.5     |
| 7       | 0.625    | ~ -0.375   |
| 8       | 0.75     | ~ -0.25    |
| 9       | 0.875    | ~ -0.125   |
| 10      | 1        | 0               |
| 11      | 1.25     | ~ 0.25    |
| 12      | 1.5      | ~ 0.5     |
| 13      | 1.75     | ~ 0.75    |
| 14      | 2        | ~ 1       |

- For **hyprmcsr**, you can set the value directly as `"sensitivity"` in your [profile](004-configuration.md#profile-config-profileprofilejson) (libinput value).

**Important:**  
You also need to set mouse acceleration to `flat`.

- **Permanent:** In your `hyprland.conf`, set:  
  ```
  input {
    accel_profile = flat
  }
  ```
- **Dynamically:** You can also set it at runtime with  
  ```
  hyprctl keyword input:accel_profile flat
  ```

---

> Back to [OBS Setup](./013-obs-setup.md)
