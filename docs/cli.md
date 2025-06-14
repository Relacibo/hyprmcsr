# hyprmcsr CLI

The `hyprmcsr` script is the main entry point for all automation tasks in this toolkit.

## Usage

You can run it directly from the `bin/` folder, or add it to your `$PATH` for convenience:

```bash
export PATH="$PATH:/path/to/hyprmcsr/bin"
```

Now you can use `hyprmcsr` from anywhere in your terminal.

## Common commands

- `hyprmcsr start`  
  Start your configured profile and all automation (window management, audio splitting, input remapping, etc.).

- `hyprmcsr destroy`  
  Clean up and reset everything (undoes remapping, closes virtual devices, etc.).

- `hyprmcsr install`  
  Download required JARs and set up dependencies (see [Automatic JAR Download](./jar-download.md)).

- `hyprmcsr run-jar modcheck`  
  Run the ModCheck tool to verify your mods (see [ModCheck](./jar-download.md#modcheck)).

## More

For advanced usage and troubleshooting, see the other chapters in this documentation.
