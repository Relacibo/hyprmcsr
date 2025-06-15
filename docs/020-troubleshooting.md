# Troubleshooting

- **Minecraft window not detected:**  
  Check your `windowClassRegex` in the profile config and verify with `hyprctl clients -j`.

- **Audio not split:**  
  Ensure Pipewire is running and the virtual sink exists.

- **Keybinds not working:**  
  Make sure hyprctl is running and your binds are not conflicting with Hyprland or system shortcuts.

- **Input remapper not working:**  
  Check group membership and permissions.
