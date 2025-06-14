# hyprmcsr


<img src="https://raw.githubusercontent.com/hyprwm/Hyprland/main/resources/logo.png" width="640" height="320" alt="banner">

> **Note:**  
> This project and its documentation are still experimental and under active development.  
> [See the full documentation in the `docs/` folder.](./docs/README.md)

## Overview

**hyprmcsr** is a toolkit for automating a modern Minecraft speedrunning environment on Linux, with a focus on performance, usability, and automation.  
It is especially useful for runners looking for a streamlined, performant alternative to the typical Windows-based MCSR setup.

The toolkit leverages [Hyprland](https://hyprland.org/) (Wayland compositor), Pipewire, PrismLauncher, and various helper tools to provide:
- Automated window management and keybinds
- Audio splitting for game/Discord/OBS
- Input remapping for optimal controls
- Easy mod and tool management (auto-download)
- Integration with OBS and other speedrun helpers

All core functionality is controlled via the `hyprmcsr` CLI, which manages setup, teardown, and automation for your speedrun sessions.

---

## Quick Links

- [Getting Started & Table of Contents](./docs/README.md)
- [Cloning and Installation](./docs/cloning-and-installation.md)
- [Usage](./docs/usage.md)
- [Configuration](./docs/configuration.md)
- [OBS Setup](./docs/obs-setup.md)
- [PrismLauncher](./docs/prismlauncher.md)
- [Mod Management & Optional Tools](./docs/jar-download.md)
- [Troubleshooting](./docs/troubleshooting.md)

---


## Contributers

- Me ([youtube](https://www.youtube.com/@relacibo), [speedrun.com](https://www.speedrun.com/de-DE/users/Relacibo))
- [Igelway](https://github.com/Igelway) ([youtube](https://www.youtube.com/@MisterKenway), [speedrun.com](https://www.speedrun.com/de-DE/users/Igelway))

## License

- All project code is under the [MIT License](LICENSE).
- Some components (like obs-vkcapture, InputRemapper) have their own licenses—see the respective files.

---

**This README and parts of the automation were created with help from [GitHub Copilot](https://github.com/features/copilot).**

**Questions or issues?**  
Check the script comments or [open an issue](https://github.com/Relacibo/hyprmcsr/issues)!
