# Comparison: hyprmcsr vs Other Tools

> **Note:**  
> This table was generated with the help of an AI and may contain inaccuracies or outdated information. Please always check the official documentation of each project for the latest details.
> This comparison is also a work in progress and should not be relied upon for critical decisions.

| Feature/Tool      | hyprmcsr (Hyprland/Wayland) | Jingle ([DuncanRuns/Jingle](https://github.com/DuncanRuns/Jingle)) | Resetti ([tesselslate/resetti](https://github.com/tesselslate/resetti)) | Waywall ([tesselslate/waywall](https://github.com/tesselslate/waywall)) |
|-------------------|----------------------------|-----------------------|--------------------|-------------------|
| **Platform**      | Linux (Hyprland/Wayland)   | Windows only          | Linux (i3/X11)     | Linux (Wayland)   |
| **Window Manager Integration** | Hyprland (Wayland) | N/A (Windows)         | i3/X11            | Wayland (Waywall) |
| **Automated Window Management** | Yes              | Yes                  | Yes               | Yes               |
| **Audio Splitting**             | Pipewire, auto    | Yes (Windows)        | Manual            | Pipewire, manual  |
| **Input Remapping**             | Input Remapper (user config) | Built-in (Jingle) | Manual            | Manual            |
| **OBS Integration**             | Yes (auto scene, vkcapture) | Yes (auto scene)  | No                | No                |
| **Mod/Tool Auto-Download**      | Yes              | No                   | No                | No                |
| **Profile System**              | Yes (JSON)        | Yes (YAML)           | No                | No                |
| **Wayland Support**             | Native            | No                   | Partial (Sway)    | Native            |
| **X11 Support**                 | No                | No                   | Yes               | No                |
| **Active Maintenance**          | Yes               | Yes                  | No                | Yes               |
| **Target Audience**             | Hyprland/Wayland users | Windows users     | i3 users          | Wayland users (Minecraft SR) |
| **Special Requirements**        | None              | None                 | None              | Patched GLFW (can be set as custom GLFW in PrismLauncher) |

## Links

- [Jingle](https://github.com/DuncanRuns/Jingle) *(Windows only)*
- [Resetti](https://github.com/tesselslate/resetti)
- [Waywall](https://github.com/tesselslate/waywall)

---

**Note:**  
- Jingle is a Windows-only tool.  
- Resetti and Jingle are more focused on i3/X11 or Windows setups, while hyprmcsr is designed for Hyprland/Wayland.
- hyprmcsr automates more setup steps (audio, window, mods) but expects you to configure input-remapper yourself.
- Waywall is also made specifically for Minecraft speedrunning and requires a patched GLFW (not Minecraft itself); you can set this as a custom GLFW in PrismLauncher.
