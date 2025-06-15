# OBS Setup

For capturing Minecraft, this setup uses [obs-vkcapture](https://github.com/nowrep/obs-vkcapture).
You should install the Flatpak versions of both OBS Studio and PrismLauncher, as well as the Flatpak version of obs-vkcapture.

## Installation (Flatpak)

You can install OBS Studio and obs-vkcapture via Flatpak with:

```bash
flatpak install flathub com.obsproject.Studio
flatpak install flathub com.obsproject.Studio.Plugin.OBSVkCapture
```

Make sure you have Flatpak and the Flathub repository enabled on your system.

## Minecraft Capture

### Monitor recording (Recommended)
Just use the monitor recording with Pipewire on which Minecraft is running, as it will capture the cursor with no problems.

### With OBS-Capture
- Set `"prismWrapperCommand": { "autoReplace": true, "innerCommand": "obs-gamecapture" }` in your profile config under the `"minecraft"` section.
- This will automatically wrap Minecraft with obs-gamecapture.

**Limitations:**
- Currently, the monitor where Minecraft runs must be positioned at the very top-left of your monitor setup, for the mouse to be recorded, if it is recorded at all...

## Boat Eye

Für die Einrichtung und Automatisierung des "Boat Eye"-Modus siehe das separate Kapitel:  
➡️ [Boat Eye Mode](./016-boateye.md)

Dort findest du alle Details zu OBS-Szenen, Transformationen, Sensitivität und automatischem Ein-/Ausblenden per obs-cli.

## Automation

hyprmcsr can control OBS via [obs-cli](https://github.com/pschmitt/obs-cli) and the OBS websocket (authentication can be disabled for simplicity).
Example usage:
```bash
...
  "boat-eye": {
    ...
    "onEnter": [
      "~/.local/bin/obs-cli item show --scene BoatEyeScene GameCapture"
    ],
    "onExit": [
      "~/.local/bin/obs-cli item hide --scene BoatEyeScene GameCapture"
    ]
}
```
