# Mod Management & Optional Tools

hyprmcsr can automatically download and update required JARs for your speedrun setup using the `hyprmcsr run-jar` command.

## How it works

- The required JARs are defined in `~/.config/hyprmcsr/repositories.json` under the `jar` object.
- When you run `hyprmcsr run-jar <jar-name>`, the JAR is automatically downloaded from the latest GitHub release if not present.
- Updates are handled automatically - if a newer version is available on GitHub, it will be downloaded and old versions removed.

## Configuration Format

The `repositories.json` file (located in `~/.config/hyprmcsr/repositories.json`) contains a `jar` object mapping JAR names to GitHub repositories:

```json
{
  "jar": {
    "ninjabrain-bot": "Ninjabrain1/Ninjabrain-Bot",
    "ninjalink": "DuncanRuns/NinjaLink",
    "paceman": "PaceMan-MCSR/PaceMan-Tracker",
    "modcheck": "tildejustin/modcheck"
  }
}
```

You can then start these tools in your `onStart` section using the JAR names defined above, for example:

```json
"onStart": [
  "hyprmcsr run-jar ninjabrain-bot",
  "hyprmcsr run-jar ninjalink"
]
```

## Ninjabrain Bot, NinjaLink, PaceMan-Tracker

[Ninjabrain Bot](https://github.com/Ninjabrain1/Ninjabrain-Bot), [NinjaLink](https://github.com/DuncanRuns/NinjaLink) and [PaceMan-Tracker](https://github.com/PaceMan-MCSR/PaceMan-Tracker) are examples of JAR files that you might want to have in the `onStart` section of your profile config.
  
## ModCheck

- [ModCheck](https://github.com/tildejustin/modcheck) is a tool to download and update the mods of your minecraft instance.
- You can run it at any time with:

  ```bash
  hyprmcsr run-jar modcheck
  ```

  This will launch the ModCheck GUI.


---

## Optional Tools

You can use additional tools for automation in your `onStart`, `onEnter`, `onExit`, or custom binds in your profile config, like:

- [**razer-cli**](https://github.com/lolei/razer-cli)  
  Command-line tool to set DPI and other settings for Razer mice.

- [**obs-cli**](https://github.com/pschmitt/obs-cli)  
  Command-line client for OBS Studio, allowing you to control scenes, sources, and more from scripts.

You can add more tools as needed for your workflow.
