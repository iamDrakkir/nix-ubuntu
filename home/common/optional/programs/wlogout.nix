{
  config,
  lib,
  pkgs,
  homeDirectory,
  ...
}:

{
  home.packages = [ pkgs.wlogout ];

  # Symlink config from dotfiles repo
  home.file = lib.custom.symlink.mkDotfilesLinks config homeDirectory [ "wlogout" ];
}
