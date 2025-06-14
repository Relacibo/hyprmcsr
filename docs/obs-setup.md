# OBS Setup

## Installation (Flatpak)

You can install OBS Studio and obs-vkcapture via Flatpak with:

```bash
flatpak install flathub com.obsproject.Studio
flatpak install flathub com.obsproject.Studio.Plugin.OBSVkCapture
```

Make sure you have Flatpak and the Flathub repository enabled on your system.

## Usage

- Use monitor capture for best compatibility, or obs-gamecapture for direct game capture.
- For "Boat Eye" mode, create a separate scene with a resized game capture source.

**Automation:**  
hyprmcsr can control OBS via [obs-cli](https://github.com/pschmitt/obs-cli) and the OBS websocket (authentication can be disabled for simplicity).
