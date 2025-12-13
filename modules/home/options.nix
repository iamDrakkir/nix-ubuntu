{ lib, ... }:

{
  options.myConfig = {
    desktop = {
      gnome.enable = lib.mkEnableOption "GNOME desktop environment";
      hyprland.enable = lib.mkEnableOption "Hyprland compositor";
      niri.enable = lib.mkEnableOption "Niri compositor";
    };
    
    features = {
      gaming.enable = lib.mkEnableOption "gaming packages (Steam, Lutris, etc.)";
      development.enable = lib.mkEnableOption "development tools";
    };
  };
}
