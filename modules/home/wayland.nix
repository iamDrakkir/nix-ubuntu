{ config, lib, pkgs, ... }:

{
  # Shared Wayland utilities for all Wayland compositors
  config = lib.mkIf (
    config.myConfig.desktop.hyprland.enable ||
    config.myConfig.desktop.niri.enable
  ) {
    home.packages = with pkgs; [
      grim        # Screenshot tool
      slurp       # Screen area selector
      wl-clipboard # Clipboard utilities
      wl-clipboard-x11 # X11 compatibility
    ];
  };
}
