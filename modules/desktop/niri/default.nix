{ pkgs, ... }:

{
  # Niri configuration would go here when needed
  # For now, just ensure the package is available
  
  home.packages = with pkgs; [
    niri
    # Wayland utilities (shared with Hyprland)
    grim
    slurp
    wl-clipboard
  ];
}
