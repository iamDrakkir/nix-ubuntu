{ ... }:

{
  profile = {
    name = "terra";
    
    git = {
      userName = "iamDrakkir";
      userEmail = "Hagelin.Rickard@gmail.com";
      githubUsername = "iamDrakkir";
    };

    machine = {
      hostname = "terra";
      isLaptop = false;  # Stationary desktop
    };
  };

  # Enable desktop environments for Terra
  myConfig.desktop = {
    gnome.enable = true;
    hyprland.enable = true;
    niri.enable = true;
  };

  # Enable features for Terra
  myConfig.features = {
    gaming.enable = true;
    development.enable = true;
  };
}
