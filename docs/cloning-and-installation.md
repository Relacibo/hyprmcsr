# Cloning and Installation

This section explains how to clone the hyprmcsr repository and set up the initial configuration.

## 1. Clone the repository

```bash
git clone https://github.com/relacibo/hyprmcsr.git
cd hyprmcsr
```

## 2. Add hyprmcsr to your PATH

For convenience, add the `bin/` directory to your `PATH` so you can use the `hyprmcsr` CLI from anywhere:

```bash
export PATH="$PATH:$(pwd)/bin"
```

You can also add this line to your `.bashrc` or `.zshrc` for persistence.

> For more details, see [hyprmcsr CLI](./cli.md).

## 3. Run the install command

```bash
hyprmcsr install
```
This command will:
- Download required JARs
- Create default configuration files
- Setup the audio-splitting, if enabled in the *.profile.json (Is disabled by default)

## 4. Configuration files

- **Global configuration:**  
  `config.json` (created from `example.config.json` on first install)

- **Default profile configuration:**  
  `default.profile.json` (created from `example.default.profile.json` on first install)

You can create additional profiles by copying and editing the example profile.

> **Tip:**  
> If you want to use a different profile, specify it when starting hyprmcsr or set the `HYPRMCSR_PROFILE` environment variable.

Continue with the [CLI usage](./cli.md) or other chapters for more details.
