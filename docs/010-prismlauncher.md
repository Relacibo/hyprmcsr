# PrismLauncher & Minecraft Setup

PrismLauncher is required to manage your Minecraft instances for speedrunning.
You can use the **Flatpak version** aswell as the native version.

## Installation (Native)

You can install PrismLauncher natively on your system with your package manager. For example, on Fedora:

```bash
sudo dnf install prismlauncher
```

Or on Arch Linux:

```bash
sudo pacman -S prismlauncher
```

Or on Ubuntu/Debian:

```bash
sudo apt install prismlauncher
```

> **Note:**
> If you want to use Flatpak, see [Flatpak Setup](./030-flatpak.md) for details and limitations. The recommended and supported way is the native installation.

## LWJGL Version

For best compatibility with modern Linux systems, Wayland, and input handling, you should always use the latest stable version of LWJGL (Lightweight Java Game Library) in your PrismLauncher Minecraft instance.

**How to update LWJGL in PrismLauncher:**
1. Open PrismLauncher and select your Minecraft instance.
2. Click on "Edit Instance".
3. Go to "Version" → "LWJGL Version".
4. Select the latest available LWJGL version (preferably 3.3.x or newer).
5. Save and launch Minecraft again.

## Java Version & JVM Flags

For best performance and compatibility, it is recommended to:

- Open your Minecraft instance settings in PrismLauncher.
- Enable the option to use a custom Java version for the instance.
- Disable the Java compatibility check.
- Set the Java version to a preinstalled Java (preferably GraalVM or any modern JDK, Java 21+ is recommended). To use the system version of java use `/usr/bin/java`.
- For optimal JVM flags, see the recommendations in [Osh's video at 4:40](https://youtu.be/OEpZlv6cQsI?si=Pv2prKsP1xYSzXIc&t=280).

> **Note:**
> Flatpak users: See [Flatpak Setup](./030-flatpak.md) for details and limitations. Native installation is strongly recommended for best compatibility.

This setup ensures maximum performance and compatibility for speedrunning and modded Minecraft.

## Wrapper Command

hyprmcsr can automatically configure the wrapper command for your PrismLauncher instances.

### Automatic Configuration (Recommended)

When you set `autoReplaceWrapperCommand.enabled: true` in your profile config, hyprmcsr will automatically configure the `instance_wrapper.sh` as the wrapper command for your specified instance(s).

**Do not** manually set a wrapper script in the PrismLauncher GUI when using automatic configuration - it will be overwritten.

Example configuration:

```json
"prismLauncher": {
  "autoReplaceWrapperCommand": {
    "enabled": true,
    "innerCommand": "obs-gamecapture"
  },
  "instanceId": "1.16.1"
}
```

If you want to use only the hyprmcsr wrapper without an inner command:

```json
"prismLauncher": {
  "autoReplaceWrapperCommand": {
    "enabled": true
  },
  "instanceId": "1.16.1"
}
```

### Manual Configuration

If you prefer to manage the wrapper manually, simply omit the `autoReplaceWrapperCommand` section or set `enabled: false`. Then you can configure the wrapper in the PrismLauncher GUI. If you do this, make sure to include `hyprmcsr -h <profile> instance-wrapper` in your wrapper command chain.

### Auto-Launch Minecraft

You can automatically start Minecraft when running `hyprmcsr run` by setting `autoLaunch: true`:

```json
"prismLauncher": {
  "instanceId": "1.16.1",
  "autoLaunch": true
}
```

This is equivalent to running `prismlauncher -l "1.16.1"` automatically on start.

> **Tip:** The instance ID should be the folder name of your instance (as found in `~/.local/share/PrismLauncher/instances/`), not the display name in PrismLauncher.

## Download Mods

You can easily download and update all recommended mods and helper tools for your Minecraft instance using [modcheck](https://github.com/tildejustin/modcheck). See: [Modcheck](https://github.com/Relacibo/hyprmcsr/blob/main/docs/015-jar-download.md#modcheck) for details and instructions.
