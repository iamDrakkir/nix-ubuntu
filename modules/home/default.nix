{ ... }:

{
  imports = [
    ./profile-options.nix
    ./options.nix
    ./cli.nix
    ./gui.nix
    ./gaming.nix
    ./wayland.nix
    ./dotfiles.nix
    ./flatpak.nix
    ./sessions.nix
    ./programs/git.nix
    ./programs/zen-browser.nix
  ];
}
