{
  lib,
  pkgs,
  ...
}:

{
  home.packages = with pkgs; [
    proton-pass
    protonvpn-gui
    proton-pass-cli
  ];
}
