{
  inputs,
  username,
  homeDirectory,
  ...
}:

{
  imports = [
    ../common/core
    ./common/git.nix

    # Desktop environments
    ../common/optional/desktops/gnome
    ../common/optional/desktops/hyprland
    ../common/optional/desktops/niri

    # Features
    ../common/optional/development.nix
    ../common/optional/gaming.nix
    ../common/optional/tools

    # System
    ../common/optional/flatpak.nix
    ../common/optional/sessions.nix
    ../common/optional/programs
  ];
}
