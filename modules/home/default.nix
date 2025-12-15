{ ... }:

{
  imports = [
    ./options.nix
    ./cli.nix
    ./gui.nix
    ./git.nix
    ./gaming.nix
    ./wayland.nix
    ./dotfiles.nix
    ./flatpak.nix
    ./sessions.nix
    ./programs/zen-browser.nix
  ];
}
