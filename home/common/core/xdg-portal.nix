{ homeDirectory, pkgs, ... }:

{
  # Configure systemd user environment to find portal service files
  xdg.configFile."systemd/user.conf" = {
    text = ''
      [Manager]
      ManagerEnvironment="XDG_DATA_DIRS=/usr/local/share:/usr/share:${homeDirectory}/.local/state/nix/profiles/profile/share/:/nix/var/nix/profiles/default/share"
    '';
  };
  xdg.portal = {
    config = {
      gnome = {
        default = [
          "gnome"
          "gtk"
        ];
        "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
      };
      hyprland = {
        default = [
          "hyprland"
          "gtk"
        ];
        "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
      };
      niri = {
        default = [
          "gnome"
          "gtk"
        ];
        "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
      };
    };
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
    ];
  };
}
