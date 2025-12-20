{
  config,
  lib,
  homeDirectory,
  ...
}:

{
  # NOTE: neovim is installed by system-manager in hosts/common/core/nix.nix
  # This module only handles the config symlink

  # Symlink config from dotfiles repo
  home.file = lib.custom.symlink.mkDotfilesLinks config homeDirectory [ "nvim" ];
}
