# Boat Eye Mode

The "Boat Eye" mode is a special Minecraft speedrunning setup where the field of view is stretched vertically to maximize visibility while boating. To comply with speedrun.com rules, the Boat Eye view must be shown as a separate overlay in your recording and must be togglable.

## OBS Configuration

See [OBS Setup](./013-obs-setup.md) for general instructions.  
For Boat Eye, it is recommended to create a dedicated OBS scene:

1. **Create a new scene** in OBS, e.g., "BoatEyeScene".
2. **Add a dedicated Game Capture source** that captures Minecraft.
3. **Adjust the source:**
   - **Position:** Centered
   - **Size:** Set the bounding box to **half the width and half the height** of your monitor resolution (e.g., 960x540 for 1920x1080).
   - **Alignment:** Centered
4. **Project** this scene to a second monitor if desired.

## Automatic Overlay Toggle with obs-cli

To show or hide the Boat Eye overlay as required by the rules, you can use [obs-cli](https://github.com/pschmitt/obs-cli).  
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
- When Boat Eye is activated, the overlay is shown; when leaving, it is hidden.
- Adjust paths and scene names as needed for your setup.

## Mouse Sensitivity for Boat Eye

Correct pointer speed is important for precise gameplay in Boat Eye mode.  
A video explaining the settings:  
[Boat Eye Setup Guide (YouTube) by osh](https://www.youtube.com/watch?v=HcrrfsHrR_c)

**To calculate the optimal pointer speed:**  
Use this tool: [Pixel-Perfect-Tools/calc](https://priffin.github.io/Pixel-Perfect-Tools/calc.html)  
Note: The tool uses Windows pointer speed.

### Conversion Table: Windows → Linux

| Windows | xinput   | libinput   |
|---------|----------|------------|
| 1       | 0.03125  | -0.96875   |
| 2       | 0.0625   | -0.9375    |
| 3       | 0.125    | -0.875     |
| 4       | 0.25     | -0.75      |
| 5       | 0.375    | -0.625     |
| 6       | 0.5      | -0.5       |
| 7       | 0.625    | -0.375     |
| 8       | 0.75     | -0.25      |
| 9       | 0.875    | -0.125     |
| 10      | 1        | 0          |
| 11      | 1.25     | 0.25       |
| 12      | 1.5      | 0.5        |
| 13      | 1.75     | 0.75       |
| 14      | 2        | 1          |

- For hyprmcsr, you can set the value directly as `"sensitivity"` in your profile (libinput value recommended).

---

> Back to [OBS Setup](./013-obs-setup.md)
