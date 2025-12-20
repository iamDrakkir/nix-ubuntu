{ pkgs, ... }:

{
  # System-level flatpak package
  # Installed on hosts that need it (terra, bigbox)
  environment.systemPackages = with pkgs; [
    flatpak
  ];
}
