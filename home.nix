{ pkgs, inputs, system, username, homeDirectory, ... }:
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

  # Zen browser
  home.packages = [
    inputs.zen-browser.packages.${system}.default
  ];

  programs.home-manager.enable = true;
}
