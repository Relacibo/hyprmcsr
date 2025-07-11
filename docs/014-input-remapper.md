# Input Remapper

You can use [input-remapper](https://github.com/sezanzeb/input-remapper) to remap your keyboard or mouse inputs to other keys or buttons for optimal speedrunning.

- hyprmcsr does **not** manage input-remapper for you automatically.
- You must add all input-remapper commands explicitly to your profile's `onStart` and `onDestroy` arrays.
- This gives you full control over which devices and profiles are started or stopped.

**Installation (Fedora):**  
You can install input-remapper on Fedora with:
```bash
sudo dnf install input-remapper
```
Or get the latest version from [the GitHub releases page](https://github.com/sezanzeb/input-remapper/releases).

**Tip:**  
Before using hyprmcsr, you should use the input-remapper GUI (`input-remapper-gtk`) to create and test profiles for your specific devices.  
Once you have working profiles, add the appropriate `input-remapper-control` commands to your profile's `onStart` and `onDestroy` arrays for automatic activation and cleanup.

**Example profile section:**
```json
{
  "requireSudo": true,
  "onStart": [
    "sudo input-remapper-control --command start --device \"Ducky Ducky One 3 TKL \" --preset \"MCSR\"",
    "input-remapper-control --command start --device \"Razer Razer Viper V3 Pro\" --preset \"MCSR\""
  ],
  "onDestroy": [
    "sudo input-remapper-control --command stop-all"
  ]
}
```

You can list all available device names with:
```bash
input-remapper-control --list-devices | sed 's/.*/"&"/'
```
**Tip:**  
This wraps each device name in double quotes, so you can see and copy the exact name—including any trailing whitespace—into your profile.

**Important:**  
Do **not** press any keys or mouse buttons while input-remapper is applying or removing remaps!  
Otherwise, unexpected errors or malfunctions with your input devices may occur.

Make sure your user is in the `input` group and you have `sudo` permissions for input-remapper.
