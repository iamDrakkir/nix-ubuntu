{ ... }:

{
  # NOTE: no display config here — bigbox uses whatever the compositor
  # auto-detects. Add programs.niri.settings.outputs /
  # wayland.windowManager.hyprland.settings.monitor here if that changes
  # (see home/drakkir/terra.nix for the shape).
  # Symlink .face file for user avatar
  home.file.".face".source = ../../.face;

  imports = [
    ../common/core
    ./common/ssh.nix

    # Desktop environments
    ../common/optional/desktops/gnome
    ../common/optional/desktops/hyprland
    ../common/optional/desktops/niri

    # Features
    ../common/optional/containers.nix
    ../common/optional/development.nix
    ../common/optional/gaming.nix

    # Apps
    ../common/optional/apps/discord.nix
    ../common/optional/apps/proton.nix
    ../common/optional/apps/qbittorrent.nix
    ../common/optional/apps/tmux.nix
    ../common/optional/apps/vlc.nix
    ../common/optional/apps/vscode.nix

    # System
    ../common/optional/flatpak.nix
    ../common/optional/pam-shim.nix
  ];
}
