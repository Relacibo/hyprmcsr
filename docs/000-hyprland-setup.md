# Hyprland Setup

Hyprland is required for this project.  
It is a modern Wayland compositor that enables advanced window management and performance optimizations.

> **Note:**  
> hyprmcsr has so far only been tested on **Fedora 42**. Other distributions are supported in principle, but may require additional troubleshooting.

## Supported Distributions

Hyprland works best on:
- **Fedora** (recommended for beginners, easy setup)
- **Arch Linux** (and derivatives like EndeavourOS, Garuda)
- **NixOS**
- **Ubuntu** (with some manual steps)
- **openSUSE** (Tumbleweed)

> For the smoothest experience, use a distribution with up-to-date Wayland and Pipewire support.

## Installation

Follow the [official Hyprland installation guide](https://wiki.hyprland.org/Getting-Started/Installation/) for your distribution.

**Short summary for common distros:**

- **Fedora:**
  ```bash
  sudo dnf copr enable solopasha/hyprland
  sudo dnf install hyprland
  ```
- **Arch Linux:**
  ```bash
  sudo pacman -S hyprland
  ```
- **NixOS:**  
  See [Hyprland on NixOS](https://wiki.hyprland.org/Nix/Hyprland-on-NixOS/)

- **Ubuntu:**  
  Use a community repo or build from source (see [Hyprland Wiki](https://wiki.hyprland.org/Getting-Started/Installation/))

## Logging in to Hyprland

1. **Log out** of your current session.
2. On the login screen (display manager), select **Hyprland** as your session type.
3. Log in as usual.

- To verify you are running Wayland with Hyprland, run:
  ```bash
  echo $XDG_SESSION_TYPE
  ```
  This should output `wayland`.

**Tip:**  
For a comprehensive walkthrough of Hyprland features, configuration, and customization, see the [official Hyprland Master Tutorial](https://wiki.hypr.land/Getting-Started/Master-Tutorial/).

Be sure to check out the [Must-have Utilities](https://wiki.hypr.land/Useful-Utilities/Must-have) page for essential tools that improve your Hyprland experience (e.g., screenshot tools, clipboard managers, notification daemons, etc.).

For more details, troubleshooting, and advanced configuration, see the [official Hyprland Wiki](https://wiki.hyprland.org/).

---

Continue with [Cloning and Installation](./001-cloning-and-installation.md)
