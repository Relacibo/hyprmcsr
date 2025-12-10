# Audio Splitting

hyprmcsr uses Pipewire loopback to automatically split Minecraft audio into a separate virtual device.

## Enabling Audio Splitting

By default, audio splitting is **disabled**.  
To enable it, run:

```bash
hyprmcsr setup-audio-splitter enable
```

This will automatically detect your current default output device and configure Pipewire to create virtual audio devices for splitting. You can also specify a custom playback target:

```bash
hyprmcsr setup-audio-splitter enable <playback_target>
```

## Usage

- When Minecraft starts, its audio will be automatically moved to the virtual device **GameSound**.
- In OBS, you can select the **GameSound** device as an audio source for clean game audio capture.
- In Discord, you should manually set your output device to **DiscordSound** to also split your discord sound into a separate virtual output.
- This allows you to record or stream game audio and Discord audio as separate sources in OBS.

## Disabling Audio Splitting

To disable audio splitting and remove the virtual outputs (GameSound, DiscordSound, etc.), run:

```bash
hyprmcsr setup-audio-splitter disable
```

---

**Tip:**  
You can re-enable audio splitting at any time with a different playback target by running `hyprmcsr setup-audio-splitter enable <new_target>`.

**Troubleshooting:**  
If audio is not split, check your Pipewire setup and see [Troubleshooting](./020-troubleshooting.md).
