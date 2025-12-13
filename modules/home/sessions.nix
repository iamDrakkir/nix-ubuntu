{ config, pkgs, ... }:

{
  # Create desktop session files for Hyprland and Niri
  # These allow them to appear in your display manager's session list
  # Note: GDM doesn't follow symlinks to Nix store, so these need to be copied
  home.file.".local/share/wayland-sessions/hyprland.desktop".text = ''
    [Desktop Entry]
    Name=Hyprland
    Comment=An dynamic tiling Wayland compositor
    Exec=${config.home.homeDirectory}/.nix-profile/bin/Hyprland
    Type=Application
    DesktopNames=Hyprland
  '';

  home.file.".local/share/wayland-sessions/niri.desktop".text = ''
    [Desktop Entry]
    Name=Niri
    Comment=A scrollable-tiling Wayland compositor
    Exec=${config.home.homeDirectory}/.nix-profile/bin/niri-session
    Type=Application
    DesktopNames=Niri
  '';

  # Script to copy session files to system directory
  # Run this after home-manager switch: install-wayland-sessions
  home.packages = [
    (pkgs.writeShellScriptBin "install-wayland-sessions" ''
      echo "Copying Wayland session files to /usr/share/wayland-sessions/..."
      sudo cp -f ~/.local/share/wayland-sessions/hyprland.desktop /usr/share/wayland-sessions/
      sudo cp -f ~/.local/share/wayland-sessions/niri.desktop /usr/share/wayland-sessions/
      echo "Done! Sessions will appear in GDM after logout or restart."
    '')
  ];
}
