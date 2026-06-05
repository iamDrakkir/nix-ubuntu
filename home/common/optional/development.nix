{ pkgs, ... }:

{
  programs.nix-index-database.comma.enable = true;

  home.packages = with pkgs; [
    # Node.js
    nodejs_24
    # node2nix # TODO: broken on current nixpkgs-unstable (missing npm in build)

    # Python
    uv

    # Rust
    cargo

    # C/C++
    gcc
  ];
}
