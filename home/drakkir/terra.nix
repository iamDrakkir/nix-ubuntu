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
  # TODO: common core and optional for user is missing here?

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
