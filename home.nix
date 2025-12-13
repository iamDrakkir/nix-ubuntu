{
  pkgs,
  zen-browser,
  ...
}:
{
  imports = [
    ./modules/home
    ./modules/desktop/gnome
    ./modules/desktop/hyprland
    # zen-browser.homeModules.beta
  ];

  nixpkgs.config.allowUnfree = true;

  home = {
    username = "drakkir";
    homeDirectory = "/home/drakkir";
    stateVersion = "25.11";
  };

  # Zen browser
  home.packages = with pkgs; [
    zen-browser.packages."${system}".default
  ];

  programs.home-manager.enable = true;
  # programs.zen-browser.enable = true;
}
