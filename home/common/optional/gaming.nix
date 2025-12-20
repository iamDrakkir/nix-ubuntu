{
  config,
  lib,
  pkgs,
  ...
}:

{
  home.packages = with pkgs; [
    steam
    lutris
    mangohud
    gamemode
  ];

  home.sessionVariables = {
    MANGOHUD = "1";
  };
}
