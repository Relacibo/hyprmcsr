# Mod Management & Optional Tools

hyprmcsr can automatically download and update required JARs for your speedrun setup using the `hyprmcsr install` command.

## How it works

- The required JARs are defined in your profile config under the `download.jar` array.
- On first install (or when you run `hyprmcsr install`), all listed JARs are downloaded from their respective sources.
- Updates are handled automatically if you re-run the install command.

## Ninjabrain Bot, NinjaLink, PaceMan-Tracker

- [Ninjabrain Bot](https://github.com/Ninjabrain1/Ninjabrain-Bot), [NinjaLink](https://github.com/DuncanRuns/NinjaLink) and [PaceMan-Tracker](https://github.com/PaceMan-MCSR/PaceMan-Tracker) are examples of jar files, that you might want have into the `onStart` section in your profile config.
- Their download sources are preconfigured in the default profile. They will be downloaded when running `hyprmcsr install`
  
## ModCheck

- [ModCheck](https://github.com/tildejustin/modcheck) is a tool to verify your Minecraft mods for speedrun legality.
- You can run it at any time with:

  ```bash
  hyprmcsr run-jar modcheck
  ```

  This will launch the ModCheck GUI with your current instance's mods folder preselected.


---

## Optional Tools

You can use additional tools for automation in your `onEnter`, `onExit`, or custom binds in your profile config:

- [**razer-cli**](https://github.com/lolei/razer-cli)  
  Command-line tool to set DPI and other settings for Razer mice.

- [**obs-cli**](https://github.com/pschmitt/obs-cli)  
  Command-line client for OBS Studio, allowing you to control scenes, sources, and more from scripts.

You can add more tools as needed for your workflow.

