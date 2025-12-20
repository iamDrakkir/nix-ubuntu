{
  config,
  lib,
  pkgs,
  ...
}:

{
  home.packages = with pkgs; [
    niri
    # Wayland utilities for Niri
    grim # Screenshot tool
    slurp # Screen area selector
    wl-clipboard # Clipboard utilities
    wl-clipboard-x11 # X11 compatibility
  ];
}
