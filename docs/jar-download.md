# Automatic JAR Download

hyprmcsr can automatically download and update required JARs for your speedrun setup using the `hyprmcsr install` command.

## How it works

- The required JARs are defined in your profile config under the `download.jar` array.
- On first install (or when you run `hyprmcsr install`), all listed JARs are downloaded from their respective sources.
- Updates are handled automatically if you re-run the install command.

## Ninjabrain Bot & NinjaLink

- **Ninjabrain Bot** and **NinjaLink** are supported out of the box.
- Their download sources are preconfigured in the default profile.
- They are automatically started via the `onStart` section in your config, so you don't need to launch them manually.

## ModCheck

- **ModCheck** is a tool to verify your Minecraft mods for speedrun legality.
- You can run it at any time with:

  ```bash
  hyprmcsr run-jar modcheck
  ```

  This will launch the ModCheck GUI with your current instance's mods folder preselected.
  
