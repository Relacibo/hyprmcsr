# hyprmcsr

## Overview

This project automates the setup of a Minecraft speedrunning environment on Linux using Hyprland, Pipewire, and various helper tools.  
Configuration is centralized in the `config.json` file.  
Installation and setup of required JARs, Pipewire configuration, and keybinds are handled automatically via the install script.
I only tested it on my own system: Fedora 42.
If you have problems with this library, feel free to write an issue.

---

## Requirements

Before installing, make sure you have the following dependencies installed on your system:

- **Hyprland** (Wayland compositor)
- **Pipewire** (with Flatpak support)
- **OBS Studio** (Flatpak version recommended)
- **PrismLauncher** (Flatpak version recommended)
- **obs-vkcapture** (Flatpak plugin for OBS)
- **input-remapper** (for remapping mouse and keyboard inputs)
- **jq** (for JSON parsing in shell scripts)
- **curl** (for downloading JARs and GitHub API requests)
- **git** (for cloning this repository)
- **bash** (most scripts are written for bash)

Make sure your user is in the appropriate groups (e.g., `input` for input-remapper) and that you have permission to run `sudo` commands for input-remapper control.

## Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Relacibo/hyprmcsr
   cd hyprmcsr
   ```

2. **Run the install script**
   ```bash
   ./scripts/install.sh
   ```
   - Downloads all required JARs automatically.
   - Sets up Pipewire configuration for audio splitting.
   - Uses values from your `config.json`.
   - You can rerun that script, if you want to update or you updated `pipewireLoopbackPlaybackTarget` in `config.json`

---

## Configuration (`config.json`)

All important settings are made in the `config.json` file in the project root. The NinjaLink config is also read from there.
See [config.json](config.json)

**Key fields:**
- **binds.modeSwitch**: Defines key combinations for different window modes.
- **modeSwitch**: Sets window sizes and sensitivities for each mode.
- **inputRemapper**: Devices and presets for mouse and keyboard (for input-remapper).
- **minecraft.prismInstanceId**: Name or UUID of your PrismLauncher instance.
- **minecraft.windowTitleRegex**: Regex to detect the Minecraft window.
- **pipewireLoopbackPlaybackTarget**: Audio output for Pipewire split (e.g., your headset).

---

## Usage

### Setup and Start

- **Setup and start all tools:**
  ```bash
  ./scripts/setup.sh [--coop]
  ```
  - Starts OBS, Ninjabrain-Bot, Minecraft (via Prism), sets up keybinds and audio split.
  - With `--coop`, NinjaLink for coop is started as well.

- **Restart Minecraft only:**
  ```bash
  ./scripts/minecraft.sh
  ```
  - Only starts Minecraft (e.g., when it crashed) and re-applies audio/window handling.

- **Remove keybinds and stop input remapper:**
  ```bash
  ./scripts/destroy.sh
  ```
  - Removes all keybinds and stops input-remapper.

---

## OBS Capture

For capturing Minecraft, this setup uses [obs-vkcapture](https://github.com/nowrep/obs-vkcapture).  
You should install the Flatpak versions of both OBS Studio and PrismLauncher, as well as the Flatpak version of obs-vkcapture.

**How to use:**
- In PrismLauncher, set the wrapper command for your Minecraft instance to:
  ```
  obs-gamecapture
  ```
- This will allow obs-vkcapture to hook into the Minecraft window for seamless game capture in OBS.

**Installation:**
- Install OBS Studio and PrismLauncher via Flatpak.
- Install obs-vkcapture for Flatpak OBS:
  ```bash
  flatpak install com.obsproject.Studio.Plugin.OBSVkCapture
  ```
- For more details, see the [obs-vkcapture GitHub page](https://github.com/nowrep/obs-vkcapture).

### Minecraft Capture

#### Monitor recording (Recommended)
Just use the monitor recording with pipewire on which minecraft is running, as it will capture the cursor with no problems.

#### With OBS-Capture
- Create a **Game Capture** source in your main scene that captures Minecraft.
- Set the transformation of the Game Capture source as follows:
  - **Bounding box type:** Scale to inner bounds
  - **Alignment in bounding box:** Center
  - **Bounding box size:** Set to your monitor's resolution (e.g., 1920x1080 for a 1080p monitor)

**Limitations:**
- Currently, the monitor where Minecraft runs must be positioned at the very top-left of your monitor setup, if it is recorded at all...

### Boat Eye

To use the "Boat Eye" mode, you need to set up a second scene in OBS:

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

## Notes

- The scripts are optimized for Hyprland and Pipewire.
- Most settings (devices, instance names, audio output, etc.) are controlled via `config.json`.
- Don't run the scripts with `sudo`. The scripts use `sudo`, where needed (input-remapper). That also means, that you have to type in your password, when running `start.sh` and `destroy.sh`
- You do not necessarily need to run `toggle_mode.sh`, as it is run by the from the binds, that are created in `start.sh`

---

## Contributers
- Me ([youtube](https://www.youtube.com/@relacibo), [speedrun.com](https://www.speedrun.com/de-DE/users/Relacibo))
- Igelway ([youtube](https://www.youtube.com/@MisterKenway), [speedrun.com](https://www.speedrun.com/de-DE/users/Igelway))

## License

- All project code is under the [MIT License](LICENSE).
- Some components (like obs-vkcapture, InputRemapper) have their own licenses—see the respective files.

---

**This README and parts of the automation were created with help from [GitHub Copilot](https://github.com/features/copilot).**

**Questions or issues?**  
Check the script comments or open an issue!
