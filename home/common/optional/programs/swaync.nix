{
  config,
  lib,
  pkgs,
  homeDirectory,
  ...
}:

{
  # SwayNC notification center
  home.packages = [ pkgs.swaynotificationcenter ];

  # Symlink config from dotfiles repo
  home.file = lib.custom.symlink.mkDotfilesLinks config homeDirectory [ "swaync" ];
}
