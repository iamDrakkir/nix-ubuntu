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
    zen-browser.homeModules.beta
  ];

  nixpkgs.config.allowUnfree = true;

  home = {
    username = "drakkir";
    homeDirectory = "/home/drakkir";
    stateVersion = "25.11";
  };

  # XDG Desktop Portal configuration
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
    config = {
      hyprland = {
        default = [ "hyprland" "gtk" ];
        "org.freedesktop.impl.portal.ScreenCast" = [ "hyprland" ];
        "org.freedesktop.impl.portal.Screenshot" = [ "hyprland" ];
        "org.freedesktop.impl.portal.Inhibit" = [ "hyprland" ];
        "org.freedesktop.impl.portal.KeyboardGrab" = [ "hyprland" ];
        "org.freedesktop.impl.portal.PointerGrab" = [ "hyprland" ];
        "org.freedesktop.impl.portal.Wallpaper" = [ "hyprland" ];
      };
    };
    configPackages = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
  };

  # Systemd user services for portals only (use system pipewire)
  systemd.user.services = {

    # XDG Desktop Portal services
    xdg-desktop-portal = {
      Unit = {
        Description = "XDG Desktop Portal";
        After = [ "dbus.service" ];
        Wants = [ "dbus.service" ];
      };
      Service = {
        Type = "dbus";
        BusName = "org.freedesktop.portal.Desktop";
        ExecStart = "${pkgs.xdg-desktop-portal}/libexec/xdg-desktop-portal";
        Restart = "on-failure";
        Environment = [
          "XDG_CURRENT_DESKTOP=Hyprland"
        ];
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };

    xdg-desktop-portal-hyprland = {
      Unit = {
        Description = "XDG Desktop Portal backend for Hyprland";
        After = [ "dbus.service" ];
        Before = [ "xdg-desktop-portal.service" ];
        Wants = [ "dbus.service" ];
      };
      Service = {
        Type = "dbus";
        BusName = "org.freedesktop.impl.portal.desktop.hyprland";
        ExecStart = "${pkgs.xdg-desktop-portal-hyprland}/libexec/xdg-desktop-portal-hyprland";
        Restart = "on-failure";
        Environment = [
          "XDG_CURRENT_DESKTOP=Hyprland"
        ];
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };

  # Session variables for proper portal integration
  home.sessionVariables = {
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "Hyprland";
    NIXOS_OZONE_WL = "1"; # For better Wayland support in Electron apps
  };

  # Wayland utilities
  home.packages = with pkgs; [
    grim
    slurp
    wl-clipboard
  ];

  programs.home-manager.enable = true;
  programs.zen-browser.enable = true;
}