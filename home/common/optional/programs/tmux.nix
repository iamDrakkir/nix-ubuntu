{
  config,
  lib,
  pkgs,
  homeDirectory,
  ...
}:

{
  # Install tmux package but don't use the programs.tmux module
  # since we're managing the config via dotfiles symlinks
  home.packages = [ pkgs.tmux ];

  # Symlink config from dotfiles repo
  home.file = lib.custom.symlink.mkDotfilesLinks config homeDirectory [ "tmux" ];
}
