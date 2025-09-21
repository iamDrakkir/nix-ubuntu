{
  config,
  pkgs,
  lib,
  inputs,
  zen-browser,
  flatpaks,
  ...
}:
{
    imports = [
      ./cli.nix
      ./dotfiles.nix
      ./gui.nix
      zen-browser.homeModules.beta
    ];

    home = {
      username = "drakkir";
      homeDirectory = "/home/drakkir";
      stateVersion = "25.11";
    };

    # home.packages = with pkgs; [
    #   flatpak
    # ];
    programs.home-manager.enable = true;
    programs.zen-browser.enable = true;
}

