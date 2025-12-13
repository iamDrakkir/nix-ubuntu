{ pkgs, ... }:

{
  home.packages = with pkgs; [
    bat
    btop
    curl
    eza
    fd
    fzf
    lazygit
    nerd-fonts.jetbrains-mono
    node2nix
    nodejs_24
    ripgrep
    stow
    uv
    zoxide
    zsh
    fish
    starship
    gnumake
    gcc
    fastfetch
    cargo
  ];
}

