# Audio Splitting

hyprmcsr uses Pipewire loopback to automatically split Minecraft audio into a separate virtual device.

- No manual setup required for most users.
- The default config will move Minecraft's audio stream to a virtual sink.
- You can select this sink in OBS for clean game audio capture.

**Troubleshooting:**  
If audio is not split, check your Pipewire setup and see [Troubleshooting](./troubleshooting.md).