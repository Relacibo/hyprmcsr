# OBS Setup

For capturing Minecraft, this setup uses [obs-vkcapture](https://github.com/nowrep/obs-vkcapture).

It is recommended to install the **native** versions of both OBS Studio and PrismLauncher, as well as obs-vkcapture.

## Installation (Native)

On Fedora:

```bash
sudo dnf install obs-studio
```

On Arch Linux:

```bash
sudo pacman -S obs-studio
```

On Ubuntu/Debian:

```bash
sudo apt install obs-studio
```

For obs-vkcapture, follow the instructions in the [obs-vkcapture GitHub repo](https://github.com/nowrep/obs-vkcapture#installation).

> **Note:**
> Flatpak is not recommended for OBS or PrismLauncher due to file access and integration issues. For Flatpak-specific instructions and limitations, see [Flatpak Setup](./030-flatpak.md).

## Minecraft Capture

### Monitor recording (Recommended)
Just use monitor capture with Pipewire on the monitor where Minecraft is running. This will capture the cursor without issues.

### With obs-vkcapture
- Set `"prismWrapperCommand": { "autoReplace": true, "innerCommand": "obs-gamecapture" }` in your profile config under the `"minecraft"` section.
- This will automatically wrap Minecraft with obs-gamecapture.

**Limitations:**
- Currently, the monitor where Minecraft runs must be positioned at the very top-left of your monitor setup for the mouse to be recorded, if prism and obs are installed natively. With flatpak installations it will not be recorded at all.

## Boat Eye

For setup and automation of the "Boat Eye" mode, see the dedicated chapter:  
➡️ [Boat Eye Mode](./016-boateye.md)

There you will find all details about OBS scenes, transformations, sensitivity, and automatic scene-item toggling via obs-cli.

