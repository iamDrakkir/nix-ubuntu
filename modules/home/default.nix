{ ... }:

{
  imports = [
    ./options.nix
    ./cli.nix
    ./gui.nix
    ./dotfiles.nix
    ./flatpak.nix
    ./sessions.nix
    ./programs/zen-browser.nix
  ];
}
