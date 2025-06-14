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
- Currently, the monitor where Minecraft runs must be positioned at the very top-left of your monitor setup, if it is recorded at all...

## Boat Eye

To use the "Boat Eye" mode, you need to set up a second scene in OBS:

- **Add wrapper command** if you didn't already: Add `obs-gamecapture` as a wrapper command, like above.
- **Create a new scene** in OBS specifically for Boat Eye.
- **Add a separate Game Capture source** to this scene, capturing Minecraft as usual.
- Don't use cursor capturing
- Set the transformation of the Game Capture source as follows:
  - **Position:** Centered
  - **Size:** Set the bounding box to **half the width and half the height of your monitor resolution** (e.g., 960x540 for a 1920x1080 monitor)
  - **Alignment:** Center

This ensures the Boat Eye mode is displayed correctly.
Adjust these values if you use a different monitor resolution.

You can then open this scene as a projector in OBS and keep it running on a secondary monitor while playing.

## Automation

hyprmcsr can control OBS via [obs-cli](https://github.com/pschmitt/obs-cli) and the OBS websocket (authentication can be disabled for simplicity).
