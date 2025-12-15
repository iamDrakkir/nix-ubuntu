{ config, lib, pkgs, ... }:

{
  config = lib.mkIf config.myConfig.features.gaming.enable {
    home.packages = with pkgs; [
      steam
      lutris
      mangohud
      gamemode
    ];

    # Enable MangoHud for performance monitoring
    home.sessionVariables = {
      MANGOHUD = "1";
    };
  };
}
