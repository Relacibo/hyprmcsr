# hyprmcsr

## Overview

This project automates the setup of a Minecraft speedrunning environment on Linux using Hyprland, Pipewire, and various helper tools. The focus is on simplicity and making it easy to adapt or extend for your own needs.

**Configuration is now split:**
- Global settings: `config.json` (copied from `example.config.json` on first install)
- Profile-specific settings: `<profile>.profile.json` (e.g. `default.profile.json`, copied from `example.default.profile.json`)

Installation and setup of required JARs, Pipewire configuration, and keybinds are handled automatically via the install script.

I only tested it on my own system: Fedora 42.  
If you have problems with this library, feel free to write an issue.

---

## Requirements

Before installing, make sure you have the following dependencies installed on your system and in your PATH:

- **Hyprland** (Wayland compositor)
- **Pipewire** (with Flatpak support)
- **OBS Studio** (Flatpak version)
- **java**
- **PrismLauncher** (Flatpak version)
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
   - Copies `example.config.json` to `config.json` (global config) if not present.
   - Copies `example.default.profile.json` to `default.profile.json` (profile config) if not present.
   - Downloads all JARs that are listed in `download.jar` in `config.json` automatically.
   - Sets up Pipewire configuration for audio splitting.
   - You can always rerun that script, if you want to update.

---

## Add hyprmcsr to your PATH

To use the `hyprmcsr` command from anywhere, add the `bin` directory of this project to your `PATH`.  
For example, add the following line to your `~/.bashrc` (or `~/.zshrc`):

```bash
export PATH="$PATH:/home/username/git/hyprmcsr/bin"
```

Replace `/home/username/git/hyprmcsr` with the actual path to your cloned repository.

After saving the file, reload your shell configuration:

```bash
source ~/.bashrc
```

Now you can simply run commands like:

```bash
hyprmcsr start
hyprmcsr destroy
hyprmcsr modcheck
```
from anywhere in your terminal.

---

## Configuration

### Global config: `config.json`
- Located in `~/.config/hyprmcsr/config.json`
- Contains global settings like JAR download sources, pipewire loopback, etc.

### Profile config: `<profile>.profile.json`
- Located in `~/.config/hyprmcsr/<profile>.profile.json` (e.g. `default.profile.json`)
- Contains all profile-specific settings (Minecraft instance, binds, modes, etc.)

See [example.config.json](example.config.json) and [example.default.profile.json](example.default.profile.json) for full examples.

**Key fields:**

- **onStart**: Array of shell commands/scripts to run in the background when starting (e.g. starting helper tools, OBS, etc.).  
- **onDestroy**: Array of shell commands/scripts to run in the background when stopping (e.g. cleanup, notifications, killing helper tools).
- **binds.toggleBinds**: Key combination to toggle binds.
- **binds.modeSwitch**: Key combinations for switching between window modes.
- **binds.custom**:  
  Define your own keybinds and associated commands here.  
  The commands will be executed with the environment variables `$WINDOW_ADDRESS`, `$SCRIPT_DIR`, `$PROFILE`, `$HYPRMCSR_PROFILE`, `$PRISM_INSTANCE_ID`, and `$MINECRAFT_ROOT` set.
- **modeSwitch.default**: Default window size, sensitivity, and optional `onEnter`/`onExit` arrays for commands to run when entering or exiting a mode.
- **modeSwitch.modes**: Per-mode overrides for size, sensitivity, and `onEnter`/`onExit` commands.
- **inputRemapper.devices**: List of devices and presets for input-remapper.
- **minecraft.prismPrefixOverride**: (Optional) Path to your PrismLauncher data directory.
- **minecraft.prismInstanceId**: Name or UUID of your PrismLauncher instance.
- **minecraft.windowTitleRegex**: Regex to detect the Minecraft window.
- **minecraft.observeLog.enabled**: Enable or disable log observation for Minecraft state.
- **minecraft.onStart**: Array of shell commands/scripts to run after Minecraft has started (executed by `instance_wrapper.sh`).
- **pipewireLoopback.enabled**: Enable or disable Pipewire audio loopback/splitting.
- **pipewireLoopback.playbackTarget**: Audio output for Pipewire split (e.g., your headset).  
  Tip: You can leave this field empty. If loopback is enabled, running `install.sh` will automatically detect and set your default output here.
- **download.jar**: Array of GitHub repositories (or URLs in the future) for required JARs to be downloaded automatically.
- **autoDestroyOnExit**: If true, runs cleanup automatically when the main script exits.
- **minecraft.autoStart**:  
  If `true` (default), Minecraft will be started automatically by `hyprmcsr.sh`.  
  If `false`, you must start Minecraft yourself via PrismLauncher (GUI or CLI).  
  In both cases, all post-launch actions (window handling, audio, etc.) are handled by `instance_wrapper.sh` after Minecraft starts.
- **minecraft.prismReplaceWrapperCommand**:  
  Controls whether the instance wrapper is set automatically and which inner wrapper (like obs-gamecapture) is used.  
  Example:
  ```json
  "minecraft": {
    ...
    "prismReplaceWrapperCommand": {
      "enabled": true,
      "innerWrapperCommand": "obs-gamecapture"
    }
  }
  ```
  - If `enabled` is omitted or `true`, the wrapper will be set automatically and the `instance_wrapper.sh` will be configured as the WrapperCommand for your PrismLauncher instance.
  - If `enabled` is `false`, **you must manually ensure that `instance_wrapper.sh` is set as the WrapperCommand in your PrismLauncher instance and that the environment variable `HYPRMCSR_PROFILE` is set correctly when launching Minecraft.**
  - `innerWrapperCommand` can be any wrapper tool (e.g. `"obs-gamecapture"`).
  - If you don't need a wrapper, you can omit this field.
- **minecraft.minecraftRootFolderOverride**: (Optional)  
  Set this to the absolute path of your `.minecraft` folder if you want to override the default detection.  
  Example:  
  ```json
  "minecraft": {
    "minecraftRootFolderOverride": "/home/username/custom_minecraft_folder"
  }
  ```
  If not set, the scripts will use the PrismLauncher instance config or the default path.

**Tip:**  
You can use variables like `$SCRIPT_DIR`, `$PROFILE`, `$HYPRMCSR_PROFILE`, `$PREVIOUS_MODE`, `$NEXT_MODE`, `$WINDOW_ADDRESS`, `$PRISM_INSTANCE_ID`, and `$MINECRAFT_ROOT` in your shell commands in `onStart`, `onDestroy`, `onEnter`, `onExit`, `minecraft.onStart`, and custom binds.

---

## Usage

### Setup and Start

- **Setup and start all tools:**
  ```bash
  ./scripts/hyprmcsr.sh [--coop]
  ```
  - Sets up keybinds, input remapper, and environment.
  - Automatically sets the `instance_wrapper.sh` as the "WrapperCommand" in your PrismLauncher instance config.
  - You can restart Minecraft yourself, if it crashes via PrismLauncher (GUI or CLI).
  - All post-launch actions (window handling, audio, etc.) are now handled by `instance_wrapper.sh` after Minecraft starts.

- **Remove keybinds and stop input remapper:**
  ```bash
  ./scripts/destroy.sh
  ```
  - Removes all keybinds and stops input-remapper.
  - Calls the scripts in onDestroy in your profile config.

- **Delete old Minecraft worlds:**
  ```bash
  ./scripts/delete_old_worlds.sh <regex> <keep_n>
  ```
  - Deletes all worlds in the saves folder of the current Prism instance that match `<regex>`, except for the `<keep_n>` newest ones.
  - By default, Minecraft worlds created by this setup have the prefix `Random Speedrun `.  
    Example:  
    ```bash
    ./scripts/delete_old_worlds.sh "^Random Speedrun " 50
    ```
    This will keep the 50 newest worlds with that prefix and delete the rest.
  - **Tip:** You can also call this script from your `onDestroy` array in your profile config to automatically clean up old worlds when exiting.

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
- Set `"prismReplaceWrapperCommand": { "enabled": true, "innerWrapperCommand": "obs-gamecapture" }` in your profile config under the `"minecraft"` section.
- This will automatically wrap Minecraft with obs-gamecapture.

**Limitations:**
- Currently, the monitor where Minecraft runs must be positioned at the very top-left of your monitor setup, if it is recorded at all...

### Boat Eye

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

---

## PrismLauncher & Minecraft Setup

### LWJGL Version

For best compatibility with modern Linux systems, Wayland, and input handling, you should always use the latest stable version of LWJGL (Lightweight Java Game Library) in your PrismLauncher Minecraft instance.

**Why?**  
Older versions of LWJGL may not register certain simultaneous keypresses (for example, pressing multiple movement keys at once), or may have issues with input and graphics on Wayland.

**How to update LWJGL in PrismLauncher:**
1. Open PrismLauncher and select your Minecraft instance.
2. Click on "Edit Instance".
3. Go to "Version" → "LWJGL Version".
4. Select the latest available LWJGL version (preferably 3.3.x or newer).
5. Save and launch Minecraft again.

**Important:**  
Do **not** manually set a wrapper script in the PrismLauncher GUI for your Minecraft instance if your profile config has `"prismReplaceWrapperCommand.enabled": true` (or if you omit this field).  
The automation will automatically set `instance_wrapper.sh` as the WrapperCommand for you.

If you want to use a specific wrapper (like `obs-gamecapture`), set it as `"innerWrapperCommand"` in your profile config under `"prismReplaceWrapperCommand"`.  
**Do not** set it directly in the PrismLauncher GUI, as it will be overwritten by the automation.

If you want to manage the wrapper manually, set `"prismReplaceWrapperCommand.enabled": false` in your config.  
Then you can set any wrapper you like in the PrismLauncher GUI (e.g., `obs-gamecapture`).

---

### Mod Management with modcheck.sh

You can use the included script `modcheck.sh` to automatically download and update all required mods for your setup.

**How to use:**
```bash
./scripts/modcheck.sh
```
This will run the ModCheck tool (if present in your `jars` directory) and ensure all necessary mods are downloaded and up to date for your current Minecraft instance.

If you are missing the ModCheck JAR, simply rerun the install script:
```bash
./scripts/install.sh
```
This will download all required JARs as specified in your config.

---

## Optional Tools

In the `onEnter` and `onExit` fields in your profile config (example: [example.default.profile.json](example.default.profile.json)) I use the following tools, for automation:

- [**razer-cli**](https://github.com/lolei/razer-cli)  
  Command-line tool to set DPI and other settings for Razer mice.

- [**obs-cli**](https://github.com/pschmitt/obs-cli)  
  Command-line client for OBS Studio, allowing you to control scenes, sources, and more from scripts.  

## Notes

- The scripts are made for use with Hyprland, Pipewire and Prism.
- Most settings (devices, instance names, audio output, etc.) are controlled via your profile config.
- Don't run the scripts with `sudo`. The scripts use `sudo`, where needed (input-remapper). That also means, that you have to type in your password, when running `hyprmcsr.sh`( and `destroy.sh`)
- You do not necessarily need to run `toggle_mode.sh`, as it is run by the from the binds, that are created in `hyprmcsr.sh`
- Minecraft can now be started **directly via PrismLauncher** (GUI or CLI). The script `instance_wrapper.sh` is automatically set as the "WrapperCommand" in your PrismLauncher instance and handles all post-launch automation (window handling, audio, etc.).

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
Check the script comments or [open an issue](https://github.com/Relacibo/hyprmcsr/issues)!
