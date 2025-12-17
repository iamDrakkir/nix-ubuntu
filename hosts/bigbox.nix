{ ... }:

{
  profile = {
    name = "bigbox";
    
    git = {
      userName = "iamDrakkir";
      userEmail = "Hagelin.Rickard@gmail.com";
      githubUsername = "iamDrakkir";
    };

    machine = {
      hostname = "bigbox";
      isLaptop = false;  # Stationary desktop
    };
  };

  # Enable desktop environments for bigbox
  myConfig.desktop = {
    gnome.enable = true;
    hyprland.enable = true;
    niri.enable = true;
  };

  # Enable features for bigbox
  myConfig.features = {
    gaming.enable = true;
    development.enable = true;
  };
}
