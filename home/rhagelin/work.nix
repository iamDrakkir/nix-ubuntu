{
  username,
  homeDirectory,
  ...
}:

{
  imports = [
    ../common/core
    ../common/optional
  ];

  programs.git.settings.user = { # TODO: setup for drakkir aswell and remove default from git.nix
    name = "Rickard Hagelin";
    email = "rickard.hagelin@company.com";
  };

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
