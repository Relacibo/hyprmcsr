# OBS Setup

For capturing Minecraft, this setup uses [obs-vkcapture](https://github.com/nowrep/obs-vkcapture).  
It is recommended to install the Flatpak versions of both OBS Studio and PrismLauncher, as well as the Flatpak version of obs-vkcapture.

## Installation (Flatpak)

You can install OBS Studio and obs-vkcapture via Flatpak with:

```bash
flatpak install flathub com.obsproject.Studio
flatpak install flathub com.obsproject.Studio.Plugin.OBSVkCapture
```

Make sure you have Flatpak and the Flathub repository enabled on your system.

## Minecraft Capture

### Monitor recording (Recommended)
Just use monitor capture with Pipewire on the monitor where Minecraft is running. This will capture the cursor without issues.

### With obs-vkcapture
- Set `"prismWrapperCommand": { "autoReplace": true, "innerCommand": "obs-gamecapture" }` in your profile config under the `"minecraft"` section.
- This will automatically wrap Minecraft with obs-gamecapture.

**Limitations:**
- Currently, the monitor where Minecraft runs must be positioned at the very top-left of your monitor setup for the mouse to be recorded, if it is recorded at all.

## Boat Eye

For setup and automation of the "Boat Eye" mode, see the dedicated chapter:  
➡️ [Boat Eye Mode](./016-boateye.md)

There you will find all details about OBS scenes, transformations, sensitivity, and automatic scene-item toggling via obs-cli.

