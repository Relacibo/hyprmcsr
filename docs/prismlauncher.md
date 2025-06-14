# PrismLauncher & Minecraft Setup

PrismLauncher is required to manage your Minecraft instances for speedrunning.
It is recommended to use the **Flatpak version** for best compatibility with hyprmcsr.

## Installation (Flatpak)

You can install PrismLauncher via Flatpak with:

```bash
flatpak install flathub org.prismlauncher.PrismLauncher
```

For more details and tips, see the [PrismLauncher section in the linux-mcsr guide](https://its-saanvi.github.io/linux-mcsr/launcher.html).

After installation, launch PrismLauncher and set up your Minecraft instances as usual.  
hyprmcsr will automatically detect and use your configured PrismLauncher instance.

---

## LWJGL Version

For best compatibility with modern Linux systems, Wayland, and input handling, you should always use the latest stable version of LWJGL (Lightweight Java Game Library) in your PrismLauncher Minecraft instance.

**How to update LWJGL in PrismLauncher:**
1. Open PrismLauncher and select your Minecraft instance.
2. Click on "Edit Instance".
3. Go to "Version" → "LWJGL Version".
4. Select the latest available LWJGL version (preferably 3.3.x or newer).
5. Save and launch Minecraft again.

**Important:**  
Do **not** manually set a wrapper script in the PrismLauncher GUI for your Minecraft instance if your profile config has `"prismWrapperCommand.autoReplace": true` (or if you omit this field).
The automation will automatically set `instance_wrapper.sh` as the WrapperCommand for you.

If you want to use a specific wrapper (like `obs-gamecapture`), set it as `"innerCommand"` in your profile config under `"prismWrapperCommand"`.
**Do not** set it directly in the PrismLauncher GUI, as it will be overwritten by the automation.

If you want to manage the wrapper manually, set `"prismWrapperCommand.autoReplace": false` in your config.
Then you can set any wrapper you like in the PrismLauncher GUI (e.g., `obs-gamecapture`).
