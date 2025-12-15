{ config, lib, pkgs, ... }:

{
  config = lib.mkIf config.myConfig.desktop.niri.enable {
    home.packages = with pkgs; [
      niri
    ];
  };
}
