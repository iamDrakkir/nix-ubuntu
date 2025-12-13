{ pkgs, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    package = pkgs.hyprland;
    extraConfig = builtins.readFile ./hyprland.conf;
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
    ];
    config = {
      hyprland = {
        default = [ "hyprland" "gtk" ];
        "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
      };
      gnome = {
        default = [ "gnome" "gtk" ];
        "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
      };
    };
  };

  # Configure systemd user environment to find portal service files
  xdg.configFile."systemd/user.conf".text = ''
    [Manager]
    ManagerEnvironment="XDG_DATA_DIRS=/usr/local/share:/usr/share:/home/drakkir/.local/state/nix/profiles/profile/share/:/nix/var/nix/profiles/default/share"
  '';

  # Session variables - only set general Wayland variables
  home.sessionVariables = {
    NIXOS_OZONE_WL = "1"; # For better Wayland support in Electron apps
  };

  # Wayland utilities
  home.packages = with pkgs; [
    grim
    slurp
    wl-clipboard
    hyprpanel
    hyprpaper
  ];
}
