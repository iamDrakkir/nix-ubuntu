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
    hyprland.enable = true;
    niri.enable = true;
  };

  myConfig.features = {
    gaming.enable = true;
    development.enable = true;
  };
}
