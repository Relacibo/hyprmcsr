# hyprmcsr

> **Note:**  
> This project and its documentation are still experimental and under active development.  
> [See the full documentation in the `docs/` folder.](./docs/README.md)

## Overview

This project automates the setup of a Minecraft speedrunning environment on Linux using Hyprland, Pipewire, and various helper tools. The focus is on simplicity and making it easy to adapt or extend for your own needs.

**Configuration is now split:**
- Global settings: `config.json` (copied from `example.config.json` on first install)
- Profile-specific settings: `<profile>.profile.json` (e.g. `default.profile.json`, copied from `example.default.profile.json`)

Tested on Fedora 42.  
If you have problems, feel free to open an issue.

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
