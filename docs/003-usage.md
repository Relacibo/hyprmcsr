# Usage

This section explains how to start, stop, and use hyprmcsr after installation.

## Start all tools and automation

```bash
hyprmcsr start [-p <profile>]
```
- Sets up keybinds, input remapper, and environment.
- Automatically sets the `instance_wrapper.sh` as the "WrapperCommand" in your PrismLauncher instance config.
- You can restart Minecraft yourself, if it crashes via PrismLauncher (GUI or CLI).
- All post-launch actions (window handling, audio, etc.) are now handled by `instance_wrapper.sh` after Minecraft starts.

> **Important:**  
> Do **not** press any keys or mouse buttons while input-remapper is applying or removing remaps!  
> Otherwise, unexpected errors or malfunctions with your input devices may occur.

## Remove keybinds and stop input remapper

```bash
hyprmcsr destroy
```
- Removes all keybinds and stops input-remapper.
- Calls the scripts in `onDestroy` in your profile config.
- Will be automatically called on default, but also can be turned off.

## Delete old Minecraft worlds

```bash
hyprmcsr delete_old_worlds.sh <regex> <keep_n>
```
- Deletes all worlds in the saves folder of the current Prism instance that match `<regex>`, except for the `<keep_n>` newest ones.
- By default, Minecraft worlds created by this setup have the prefix `Random Speedrun `.  
  Example:  
  ```bash
  hyprmcsr delete_old_worlds.sh "^Random Speedrun " 50
  ```
  This will keep the 50 newest worlds with that prefix and delete the rest.
- **Tip:** You can also call this script from your `onDestroy` array in your `<profile>.profile.json` to automatically clean up old worlds when exiting. Just make sure to escape the double quotes with backslashes, for example: 
  ```bash
  "onDestroy": ["$SCRIPT_DIR/scripts/delete_old_worlds.sh \"^Random Speedrun \" 50"]
  ```

---

## Next Steps

- For JAR download, Ninjabrain Bot, NinjaLink, ModCheck, and optional tools, see [Mod Management & Optional Tools](./015-jar-download.md).
- For a detailed explanation of all configuration options, see [Configuration](./004-configuration.md).
- For PrismLauncher setup, see [PrismLauncher](./010-prismlauncher.md).
- For OBS setup and capturing, see [OBS Setup](./013-obs-setup.md).
- For troubleshooting and further help, see [Troubleshooting](./020-troubleshooting.md).
