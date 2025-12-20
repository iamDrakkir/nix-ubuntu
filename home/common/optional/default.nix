{ ... }:

{
  imports = [
    ./cli.nix
    ./gui.nix
    ./gaming.nix
    ./wayland.nix
    ./flatpak.nix
    ./sessions.nix
    ./desktops
    ./programs
  ];
}
