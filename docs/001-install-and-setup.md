# Installation and Setup

This section explains how to install hyprmcsr and set up the initial configuration.

> Requirements:
> - Option A (recommended): git
> - Option B (tarball): curl, jq, tar

## 1. Install (two options)

Option A — Recommended: Clone the repository (requires git)
```bash
git clone https://github.com/Relacibo/hyprmcsr.git
cd hyprmcsr
```

Option B — Simple: Download latest release tar.gz (no git required)

- Browser:
  - Open https://github.com/Relacibo/hyprmcsr/releases and download the release tarball (Source code (tar.gz) or release artifact).
  - Extract and enter the directory:
    ```bash
    tar -xzf hyprmcsr-<version>.tar.gz
    cd <extracted-directory>
    ```


## 2. Add hyprmcsr to your PATH

Add the `bin/` directory to your PATH so the `hyprmcsr` CLI is available system-wide:

```bash
export PATH="$PATH:/path/to/hyprmcsr/bin"
```

Replace `/path/to/hyprmcsr` with the absolute path to your installation. To make this permanent, add the line to your shell profile (e.g. `~/.bashrc` or `~/.zshrc`).

> For more details, see [hyprmcsr CLI](./002-cli.md)

## 3. Run the install command

```bash
hyprmcsr install
```
This command will:
- Download required JARs
- Create default configuration files
- Set up audio splitting, if enabled in your `config.json` (disabled by default)

## 4. Configuration files

- Global configuration: `config.json` (created from `example.config.json` on first install)  
- Default profile: `default.profile.json` (created from `example.default.profile.json` on first install)

Create additional profiles by copying and editing the example profile. Use the `HYPRMCSR_PROFILE` environment variable or `-h <profile>` to select a profile.

## Updating hyprmcsr

Always update using the bundled CLI helper:

```bash
hyprmcsr update
```

`hyprmcsr update` will try to use the git CLI to update to the latest release tag when the installation is a git checkout; otherwise it falls back to downloading and extracting the latest release tarball from GitHub.

> Note: The update helper requires `curl`, `tar`, and `jq` (and optionally `git` when using the git-based path).

## Permissions

If scripts are not executable after extraction, make them executable:

```bash
chmod +x /path/to/hyprmcsr/bin/*
```

Replace `/path/to/hyprmcsr` with the actual path to your hyprmcsr installation.

### More

For optional instructions how to add the cli to PATH, continue with [CLI](002-cli.md).
For instructions on starting, stopping, and using hyprmcsr in practice, continue with [Usage](./003-usage.md).
