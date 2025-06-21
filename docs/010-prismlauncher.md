# PrismLauncher & Minecraft Setup

PrismLauncher is required to manage your Minecraft instances for speedrunning.
You can use the **Flatpak version** aswell as the native version.

## Installation (Flatpak)

You can install PrismLauncher via Flatpak with:

```bash
flatpak install flathub org.prismlauncher.PrismLauncher
```

After installation, launch PrismLauncher and set up your Minecraft instances as usual.  
hyprmcsr will automatically detect and use your configured PrismLauncher instance.

See also: [Modcheck](https://github.com/Relacibo/hyprmcsr/blob/main/docs/jar-download.md#modcheck)

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
- For Flatpak users, you might need to use [FlatSeal](https://flathub.org/apps/com.github.tchx84.Flatseal) to allow Prism to access your custom java installation. Alternatively you could use the `Download Java`-Button in Prism to download a recent version of java. You might also have success putting your java version into the folder `~/.var/app/org.prismlauncher.PrismLauncher/data/PrismLauncher/java/` and use it like for example `~/.var/app/org.prismlauncher.PrismLauncher/data/PrismLauncher/java/java-runtime-delta/bin/java`.
- For optimal JVM flags, see the recommendations in [Osh's video at 4:40](https://youtu.be/OEpZlv6cQsI?si=Pv2prKsP1xYSzXIc&t=280).

This setup ensures maximum performance and compatibility for speedrunning and modded Minecraft.

## Wrapper Command

**Important:**  
Do **not** manually set a wrapper script in the PrismLauncher GUI for your Minecraft instance if your profile config has `"prismWrapperCommand.autoReplace": true` (or if you omit this field).
The automation will automatically set `instance_wrapper.sh` as the WrapperCommand for you.

If you want to use a specific wrapper (like `obs-gamecapture`), set it as `"innerCommand"` in your profile config under `"prismWrapperCommand"`.
**Do not** set it directly in the PrismLauncher GUI, as it will be overwritten by the automation.

If you want to manage the wrapper manually, set `"prismWrapperCommand.autoReplace": false` in your config.
Then you can set any wrapper you like in the PrismLauncher GUI (e.g., `obs-gamecapture`). Remember though to also set `hyprmcsr -h <profile> instance-wrapper` as one of the wrapper commands.

**Note:**
When specifying your PrismLauncher instance IDs in your config, use the `prismWrapperCommand.prismMinecraftInstanceIds` array. Each entry should be the folder name of the instance (as found in `~/.var/app/org.prismlauncher.PrismLauncher/data/PrismLauncher/instances/` for Flatpak, or `~/.local/share/PrismLauncher/instances/` for native installs).

Example:

```json
"prismWrapperCommand": {
  "autoReplace": true,
  "prismMinecraftInstanceIds": ["1.16.1", "1.16.1(2)"],
  "innerCommand": "obs-gamecapture"
}
```

**Tip:**
You can start Minecraft directly from your onStart array using:

    flatpak run org.prismlauncher.PrismLauncher -l "<instance id>"

Replace `<instance id>` with the folder name of your instance (not the display name in PrismLauncher).

This is the recommended way to launch Minecraft from automation scripts if you installed PrismLauncher via Flatpak (the default for this guide).

> **Note:** For the wrapper command to be reliably updated in your PrismLauncher instance, PrismLauncher must not be running while the wrapper is being set. If PrismLauncher is open, it may overwrite or ignore changes made to the instance configuration file. Always close PrismLauncher before running the setup script or before starting your profile to ensure the wrapper command is applied correctly.

## Native vs Flatpak PrismLauncher

- **Flatpak PrismLauncher:**
  - Start command: `flatpak run org.prismlauncher.PrismLauncher -l "<instance id>"`
  - Data directory: `~/.var/app/org.prismlauncher.PrismLauncher/data/PrismLauncher`
- **Native PrismLauncher:**
  - Start command: `prismlauncher -l "<instance id>"`
  - Data directory: `~/.local/share/PrismLauncher`

> **Note:**
> If you use the Flatpak version, set `minecraft.prismPrefix` in your profile config to the Flatpak data directory. The default for native is `~/.local/share/PrismLauncher`.
