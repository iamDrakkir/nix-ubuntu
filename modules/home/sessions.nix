{ config, pkgs, homeDirectory, lib, ... }:

{
  # Create desktop session files for Hyprland and Niri
  # These allow them to appear in your display manager's session list
  home.file.".local/share/wayland-sessions/hyprland.desktop".text = ''
    [Desktop Entry]
    Name=Hyprland
    Comment=An dynamic tiling Wayland compositor
    Exec=${homeDirectory}/.nix-profile/bin/Hyprland
    Type=Application
    DesktopNames=Hyprland
  '';

  home.file.".local/share/wayland-sessions/niri.desktop".text = ''
    [Desktop Entry]
    Name=Niri
    Comment=A scrollable-tiling Wayland compositor
    Exec=${homeDirectory}/.nix-profile/bin/niri-session
    Type=Application
    DesktopNames=Niri
  '';

  # Automatically copy session files to system directory after home-manager activation
  # This requires sudo privileges - you may be prompted for password
  home.activation.installWaylandSessions = lib.hm.dag.entryAfter ["writeBoundary"] ''
    $DRY_RUN_CMD echo "Installing Wayland session files..."
    
    # Check if session files exist in home directory
    if [ -f "${homeDirectory}/.local/share/wayland-sessions/hyprland.desktop" ] || \
       [ -f "${homeDirectory}/.local/share/wayland-sessions/niri.desktop" ]; then
      
      # Create system wayland-sessions directory if it doesn't exist
      $DRY_RUN_CMD sudo mkdir -p /usr/share/wayland-sessions/
      
      # Copy Hyprland session file if it exists
      if [ -f "${homeDirectory}/.local/share/wayland-sessions/hyprland.desktop" ]; then
        $DRY_RUN_CMD sudo cp -f "${homeDirectory}/.local/share/wayland-sessions/hyprland.desktop" \
          /usr/share/wayland-sessions/hyprland.desktop
        $DRY_RUN_CMD echo "  ✓ Installed Hyprland session"
      fi
      
      # Copy Niri session file if it exists
      if [ -f "${homeDirectory}/.local/share/wayland-sessions/niri.desktop" ]; then
        $DRY_RUN_CMD sudo cp -f "${homeDirectory}/.local/share/wayland-sessions/niri.desktop" \
          /usr/share/wayland-sessions/niri.desktop
        $DRY_RUN_CMD echo "  ✓ Installed Niri session"
      fi
      
      $DRY_RUN_CMD echo "Session files installed. They will appear in GDM after logout."
    fi
  '';

  # Keep the manual script as a backup option
  home.packages = [
    (pkgs.writeShellScriptBin "install-wayland-sessions" ''
      echo "Copying Wayland session files to /usr/share/wayland-sessions/..."
      sudo mkdir -p /usr/share/wayland-sessions/
      sudo cp -f ~/.local/share/wayland-sessions/hyprland.desktop /usr/share/wayland-sessions/ 2>/dev/null || true
      sudo cp -f ~/.local/share/wayland-sessions/niri.desktop /usr/share/wayland-sessions/ 2>/dev/null || true
      echo "Done! Sessions will appear in GDM after logout or restart."
    '')
  ];
}
