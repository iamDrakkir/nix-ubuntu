{ inputs, username, homeDirectory, ... }:
{
  imports = [
    ./modules/home
    inputs.nix-flatpak.homeManagerModules.nix-flatpak
  ];

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
