# Usage

This section explains how to start, stop, and use hyprmcsr after installation.

## CLI options

- `-h <hyprmcsr_profile>`: Sets the global config profile (e.g. for different global setups, instances)
- `-p <profile>`: Sets the profile allowing some variants in how the profile behaves (e.g. coop, etc.)

## Start all tools and automation

```bash
hyprmcsr run
```
- Sets up keybinds, input remapper, and environment.
- Automatically sets the `instance_wrapper.sh` as the "WrapperCommand" in your PrismLauncher instance config.
- You can restart Minecraft yourself, if it crashes via PrismLauncher (GUI or CLI).
- All post-launch actions (window handling, audio, etc.) are now handled by `instance_wrapper.sh` after Minecraft starts.
- By default, `hyprmcsr destroy` will be called automatically if you cancel or close `hyprmcsr run` (e.g. with Ctrl+C), so all keybinds and remaps are cleaned up safely.

Example for an alternative profile:
```bash
hyprmcsr -p coop run
```

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
hyprmcsr delete-old-worlds <regex> <keep_n>
```
- Deletes all worlds in the saves folder of the current Prism instance that match `<regex>`, except for the `<keep_n>` newest ones.
- By default, Minecraft worlds created by this setup have the prefix `Random Speedrun `.  
  Example:  
  ```bash
  hyprmcsr delete-old-worlds "^Random Speedrun " 50
  ```
  This will keep the 50 newest worlds with that prefix and delete the rest.
- **Tip:** You can also call this script from your `onDestroy` array in your `<profile>.profile.json` to automatically clean up old worlds when exiting. Just make sure to escape the double quotes with backslashes, for example: 
  ```bash
  "onDestroy": ["$SCRIPT_DIR/delete_old_worlds.sh \"^Random Speedrun \" 50"]
  ```

## Update hyprmcsr to the latest release

To update your hyprmcsr installation to the latest official release, simply run:

```bash
hyprmcsr update
```

- This command will first try to use the git CLI to update to the latest release tag if your installation is a git repository. If git is not available, it will automatically fall back to downloading and extracting the latest release tarball from GitHub.
- All files will be updated in place. Local changes may be overwritten.
- You can run this command from anywhere; it will always update the repository where hyprmcsr is installed.
- Make sure you have write permissions for the repository directory.

> **Note:** The update script requires `curl`, `tar`, and `jq` (and optionally `git`) to be installed on your system.

---

## Next Steps

- For a detailed explanation of all configuration options, see [Configuration](./004-configuration.md).
- For PrismLauncher setup, see [PrismLauncher](./010-prismlauncher.md).
- For OBS setup and capturing, see [OBS Setup](./013-obs-setup.md).
- For troubleshooting and further help, see [Troubleshooting](./020-troubleshooting.md).
- For JAR download, Ninjabrain Bot, NinjaLink, ModCheck, and optional tools, see [Mod Management & Optional Tools](./015-jar-download.md).
