{
  config,
  lib,
  pkgs,
  ...
}:

{
  # NOTE: neovim is installed by system-manager in hosts/common/core/nix.nix
  # This module only handles the config symlink

  # imagemagick is required by snacks.image for format conversion
  home.packages = [ pkgs.imagemagick ];

  # Symlink config from dotfiles repo
  home.file = lib.custom.symlink.mkDotfilesLinks config [ "nvim" ];
}
