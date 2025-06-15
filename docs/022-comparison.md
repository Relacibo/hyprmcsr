# Comparison: hyprmcsr vs Other Tools

> **Note:**  
> This table was generated with the help of an AI and may contain inaccuracies or outdated information. Please always check the official documentation of each project for the latest details.  
> This comparison is also a work in progress and should not be relied upon for critical decisions.

| Feature/Tool      | hyprmcsr (Hyprland/Wayland) | Jingle ([DuncanRuns/Jingle](https://github.com/DuncanRuns/Jingle)) | Resetti ([tesselslate/resetti](https://github.com/tesselslate/resetti)) | Waywall ([tesselslate/waywall](https://github.com/tesselslate/waywall)) |
|-------------------|----------------------------|-----------------------|--------------------|-------------------|
| **Platform**      | Linux (Hyprland/Wayland)   | Windows only          | Linux (i3/X11)     | Linux (Wayland)   |
| **Window Manager Integration** | Hyprland (Wayland) | N/A (Windows)         | N/A, i3 recommended (X11)    | N/A (Wayland) |
| **Automated Window Management** | Yes              | Yes                  | Yes               | Yes               |
| **Audio Splitting**             | Pipewire, auto    | Yes (Windows)        | Manual            | Pipewire, manual  |
| **Input Remapping**             | Input Remapper (user config) | Built-in (Jingle) | Manual            | Manual            |
| **OBS Integration**             | With third party tools | Yes (auto scene)  | No                | No                |
| **Mod/Tool Auto-Download**      | Yes              | No                   | No                | No                |
| **Profile System**              | Yes (JSON)        | Yes (YAML)           | No                | No                |
| **Wayland Support**             | Native            | No                   | Partial (Sway)    | Native            |
| **X11 Support**                 | No                | No                   | Yes               | No                |
| **Active Maintenance**          | Yes               | Yes                  | No                | Yes               |
| **Special Requirements**        | Must be set as wrapper command in PrismLauncher; requires Hyprland | None | None | Patched GLFW (can be set as custom GLFW in PrismLauncher); must be set as wrapper command |
| **Launcher agnostic**           | No (Prism required) | Yes                  | Yes               | Maybe             |
| **Display Manager agnostic**    | No (Hyprland required) | N/A                | Yes               | Yes               |

## Links

- [Jingle](https://github.com/DuncanRuns/Jingle) *(Windows only)*
- [Resetti](https://github.com/tesselslate/resetti)
- [Waywall](https://github.com/tesselslate/waywall)

---

**Note:**  
- Jingle is a Windows-only tool.  
- Resetti and Jingle are launcher agnostic (work with any Minecraft launcher), while hyprmcsr and Waywall require PrismLauncher.
- hyprmcsr automates more setup steps (audio, window, mods) but expects you to configure input-remapper yourself.
- Both hyprmcsr and Waywall must be set as wrapper commands in PrismLauncher. Waywall requires a patched GLFW (not Minecraft itself); you can set this as a custom GLFW in PrismLauncher.
