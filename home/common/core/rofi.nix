{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Install rofi package but don't use the programs.rofi module
  # since we're managing the config via dotfiles symlinks
  home.packages = [ pkgs.rofi ];

  # Symlink config from dotfiles repo
  home.file = lib.custom.symlink.mkDotfilesLinks config [ "rofi" ];
}
