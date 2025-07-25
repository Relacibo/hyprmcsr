# Cloning and Installation

This section explains how to clone the hyprmcsr repository and set up the initial configuration.

> **Requirement:**  
> You need [git](https://git-scm.com/) installed.  
> See [Install Git on Linux](https://git-scm.com/downloads/linux) for instructions.

## 1. Clone the repository

```bash
git clone https://github.com/relacibo/hyprmcsr.git
cd hyprmcsr
```

## 2. Add hyprmcsr to your PATH

For convenience, add the `bin/` directory to your `PATH` so you can use the `hyprmcsr` CLI from anywhere:

```bash
export PATH="$PATH:/path/to/hyprmcsr/bin"
```

Replace `/path/to/hyprmcsr` with the absolute path to your cloned repository.

To make this change permanent, add the above line to your `.bashrc` or `.zshrc` (using the absolute path, not `$(pwd)`).

> For more details, see [hyprmcsr CLI](./cli.md).

## 3. Run the install command

```bash
hyprmcsr install
```
This command will:
- Download required JARs
- Create default configuration files
- Set up audio splitting, if enabled in your `config.json` (disabled by default)

## 4. Configuration files

- **Global configuration:**  
  `config.json` (created from `example.config.json` on first install)

- **Default profile configuration:**  
  `default.profile.json` (created from `example.default.profile.json` on first install)

You can create additional profiles by copying and editing the example profile.

> **Tip:**  
> If you want to use a different profile, specify it when starting hyprmcsr or set the `HYPRMCSR_PROFILE` environment variable.

## Updating hyprmcsr

To get the latest updates, run the following command in your hyprmcsr directory:

```bash
git pull
```

This will fetch and apply the newest changes from the repository.

> **Note:**  
> After updating, you can optionally run `hyprmcsr install` again to ensure all new dependencies and files are set up, but this is usually not required unless the update instructions mention it.

---

Continue with [hyprmcsr CLI](./002-cli.md) for details on available commands and CLI options.
