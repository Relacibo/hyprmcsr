# Flatpak Setup (PrismLauncher & OBS)

> **Warning:**
> Flatpak is not recommended for PrismLauncher or OBS Studio due to file access, integration, and wrapper issues. Use the native installation if possible!

## Why Flatpak is problematic

- File access is restricted by default. Many scripts, custom Java versions, and wrapper tools may not work out-of-the-box.
- You must use [FlatSeal](https://flathub.org/apps/com.github.tchx84.Flatseal) to grant PrismLauncher and OBS access to all required folders (e.g. your home, custom Java, Minecraft, etc.).
- obs-gamecapture and obs-vkcapture are harder to set up and may not work reliably with Flatpak.
- Many automation features (e.g. custom binds, wrapper scripts, log observation) require additional permissions or workarounds.

## If you still want to use Flatpak

- Install PrismLauncher and OBS Studio via Flatpak:

```bash
flatpak install flathub org.prismlauncher.PrismLauncher
flatpak install flathub com.obsproject.Studio
```

- Use FlatSeal to grant access to:
  - Your home directory (for configs, custom Java, etc.)
  - Any custom Java installation you want to use
  - Minecraft data folders
  - Host OS access (for tools like jq and other scripts that need to access files outside the Flatpak sandbox)

- For custom Java:
  - You can place your Java version in `~/.var/app/org.prismlauncher.PrismLauncher/data/PrismLauncher/java/`.
  - The binary must be at `~/.var/app/org.prismlauncher.PrismLauncher/data/PrismLauncher/java/<arbitrary-jre-name>/bin/java`

- Some features (e.g. obs-gamecapture, advanced scripting) may still not work or require further workarounds.

## Troubleshooting

- If something does not work, try the native version first.
- For more details, see the [Troubleshooting](./020-troubleshooting.md) page.

---

**Summary:**
Native installation is strongly recommended for full compatibility and ease of use. Flatpak is only for advanced users who are willing to configure permissions and accept possible limitations.
