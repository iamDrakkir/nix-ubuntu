{ inputs, username, homeDirectory, ... }:
{
  imports = [
    ./modules/home
    ./modules/desktop/gnome
    ./modules/desktop/hyprland
    ./modules/desktop/niri
    inputs.nix-flatpak.homeManagerModules.nix-flatpak
  ];

  home = {
    inherit username homeDirectory;
    stateVersion = "25.11";
  };

  programs.home-manager.enable = true;
}
