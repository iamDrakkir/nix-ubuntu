{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Node.js
    nodejs_24
    # node2nix # TODO: broken on current nixpkgs-unstable (missing npm in build)
    github-copilot-cli

    # Python
    uv

    # Rust
    cargo

    # C/C++
    gcc

    # AI agent multiplexer
    herdr
  ];
  programs.nix-index-database.comma.enable = true;
}
