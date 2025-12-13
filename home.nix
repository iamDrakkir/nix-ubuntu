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
    ./gnome.nix
    # zen-browser.homeModules.beta
  ];

  nixpkgs.config.allowUnfree = true;

  home = {
    username = "drakkir";
    homeDirectory = "/home/drakkir";
    stateVersion = "25.11";
  };

  # XDG Desktop Portal configuration
  # Note: Hyprland module already installs xdg-desktop-portal-hyprland
  # We just add GTK portal for GTK apps and configure the backends
  wayland.windowManager.hyprland = {
    enable = true;
    package =  pkgs.hyprland;
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
  # This ensures systemd can locate the portal services from nix store
  # Following https://www.freedesktop.org/software/systemd/man/systemd-system.conf.html#ManagerEnvironment=
  xdg.configFile."systemd/user.conf".text = ''
    [Manager]
    ManagerEnvironment="XDG_DATA_DIRS=/usr/local/share:/usr/share:/home/drakkir/.local/state/nix/profiles/profile/share/:/nix/var/nix/profiles/default/share"
  '';


  # Session variables - only set general Wayland variables
  # Hyprland module will set XDG_CURRENT_DESKTOP automatically when in Hyprland
  home.sessionVariables = {
    NIXOS_OZONE_WL = "1"; # For better Wayland support in Electron apps
  };

  # Wayland utilities
  home.packages = with pkgs; [
    grim
    slurp
    wl-clipboard
    zen-browser.packages."${system}".default
  ];

  programs.home-manager.enable = true;
  # programs.zen-browser.enable = true;
}
