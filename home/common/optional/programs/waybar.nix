{
  config,
  lib,
  pkgs,
  homeDirectory,
  ...
}:

{
  programs.waybar = {
    enable = true;
    package = pkgs.waybar;
  };

  # Symlink config from dotfiles repo
  home.file = lib.custom.symlink.mkDotfilesLinks config homeDirectory [ "waybar" ];
}
