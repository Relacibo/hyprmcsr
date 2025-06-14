# Input Remapper

hyprmcsr uses [input-remapper](https://github.com/sezanzeb/input-remapper) to automatically remap keys and mouse buttons for optimal speedrunning.

- Device profiles are set in your profile config.
- Remapping is enabled on start and disabled on destroy.
- No manual intervention required.

**Installation (Fedora):**  
You can install input-remapper on Fedora with:
```bash
sudo dnf install input-remapper
```
Or get the latest version from [the GitHub releases page](https://github.com/sezanzeb/input-remapper/releases).

**Tip:**  
Before using hyprmcsr, you should use the input-remapper GUI (`input-remapper-gtk`) to create and test profiles for your specific devices.  
Once you have working profiles, reference them in your profile config for automatic activation.

Make sure your user is in the `input` group and you have `sudo` permissions for input-remapper.
