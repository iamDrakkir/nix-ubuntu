{ inputs, username, homeDirectory, ... }:
{
  imports = [
    ./modules/home
    inputs.nix-flatpak.homeManagerModules.nix-flatpak
  ];

  # Enable desktop environments you want to use
  myConfig.desktop = {
    gnome.enable = true;
    hyprland.enable = true;
    niri.enable = true;
  };

  # Enable optional features
  myConfig.features = {
    gaming.enable = true;
    development.enable = true;
  };

  home = {
    inherit username homeDirectory;
    stateVersion = "25.11";
  };

  programs.home-manager.enable = true;

  # Automatic garbage collection
  nix.gc = {
    automatic = true;
    options = "--delete-older-than 30d";
  };
}
