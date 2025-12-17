{ ... }:

{
  profile = {
    name = "work-laptop";
    
    git = {
      userName = "Rickard Hagelin";  # Work name
      userEmail = "rhaglin@work-company.com";  # Update with actual work email
      githubUsername = "rhaglin";  # Work GitHub username
    };

    machine = {
      hostname = "work-laptop";
      isLaptop = true;
    };
  };

  # Enable desktop environments for work laptop
  # Minimal setup for work - only GNOME
  myConfig.desktop = {
    gnome.enable = true;
    hyprland.enable = false;
    niri.enable = false;
  };

  # Enable features for work
  myConfig.features = {
    gaming.enable = false;  # No gaming at work
    development.enable = true;
  };
}
