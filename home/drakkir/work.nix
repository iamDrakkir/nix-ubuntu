{
  inputs,
  username,
  homeDirectory,
  ...
}:

{
  imports = [
    ../common/core
    ../common/optional
  ];

  myConfig.desktop = {
    gnome.enable = true;
    hyprland.enable = false;
    niri.enable = false;
  };

  myConfig.features = {
    gaming.enable = false;
    development.enable = true;
  };
}
