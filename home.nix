{
  pkgs,
  zen-browser,
  ...
}:
{
  imports = [
    ./cli.nix
    ./dotfiles.nix
    ./gui.nix
    zen-browser.homeModules.beta
  ];

  home = {
    username = "drakkir";
    homeDirectory = "/home/drakkir";
    stateVersion = "25.11";
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gnome
      xdg-desktop-portal-gtk
    ];
    config = {
      hyprland = {
        default = [ "hyprland" "gtk" ];
        "org.freedesktop.impl.portal.ScreenCast" = [
          "gnome"
        ];
      };
    };
  };
  programs.home-manager.enable = true;
  programs.zen-browser.enable = true;
}

