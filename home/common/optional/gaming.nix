{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.mkIf config.myConfig.features.gaming.enable {
    home.packages = with pkgs; [
      steam
      lutris
      mangohud
      gamemode
    ];

    home.sessionVariables = {
      MANGOHUD = "1";
    };
  };
}
