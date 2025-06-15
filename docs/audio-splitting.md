# Audio Splitting

hyprmcsr uses Pipewire loopback to automatically split Minecraft audio into a separate virtual device.

## Enabling Audio Splitting

By default, audio splitting is **disabled** (`pipewireLoopback.enabled` is `false` in `config.json`).  
To enable it, set `"pipewireLoopback.enabled": true` in your `config.json` (usually in `~/.config/hyprmcsr/config.json`).

When you run `hyprmcsr install` and `pipewireLoopback.playbackTarget` is empty or missing, the installer will automatically detect your current default output device and set it as the playback target. Audio splitting will then be configured so that Minecraft audio is routed to this device.

## Usage

- When Minecraft starts, its audio will be automatically moved to the virtual device **GameSound**.
- In OBS, you can select the **GameSound** device as an audio source for clean game audio capture.
- In Discord, you should manually set your output device to **DiscordSound** to also split your discord sound into a separate virtual output.
- This allows you to record or stream game audio and Discord audio as separate sources in OBS.

## Disabling Audio Splitting

If you set `"pipewireLoopback.enabled": false` and run the install script again, all virtual outputs (GameSound, DiscordSound, etc.) will be removed automatically.

---

**Tip:**  
You can always check or change the playback target device by editing the `pipewireLoopback.playbackTarget` field in your config. If you want to reset it, just remove the field and re-run `hyprmcsr install`.

**Troubleshooting:**  
If audio is not split, check your Pipewire setup and see [Troubleshooting](./troubleshooting.md).
