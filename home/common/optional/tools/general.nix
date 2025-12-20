{ pkgs, ... }:

{
  home.packages = with pkgs; [
    vlc
    walker
    sherlock-launcher
    foot
    kitty
    qbittorrent
  ];
}
