{
  config,
  lib,
  pkgs,
  ...
}:

{ # TODO: most of this should be in core. and development flag is not needed. (probebly to shell.nix?)
  config = lib.mkIf config.myConfig.features.development.enable {
    home.packages = with pkgs; [
      node2nix
      nodejs_24
      stow
      uv
      gnumake
      gcc
      cargo
    ];
  };
}
