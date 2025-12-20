{
  config,
  lib,
  pkgs,
  homeDirectory,
  ...
}:

{
  # Install alacritty package but don't use the programs.alacritty module
  # since we're managing the config via dotfiles symlinks
  home.packages = [ pkgs.alacritty ];

  # Symlink config from dotfiles repo
  home.file = lib.custom.symlink.mkDotfilesLinks config homeDirectory [ "alacritty" ];
}
