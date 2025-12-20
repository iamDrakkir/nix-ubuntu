{
  config,
  lib,
  pkgs,
  homeDirectory,
  ...
}:

{
  # Install ghostty package but don't use the programs.ghostty module
  # since we're managing the config via dotfiles symlinks
  home.packages = [ pkgs.ghostty ];

  # Symlink config from dotfiles repo
  home.file = lib.custom.symlink.mkDotfilesLinks config homeDirectory [ "ghostty" ];
}
