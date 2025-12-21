{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Node.js
    nodejs_24
    node2nix

    # Python
    uv

    # Rust
    cargo

    # C/C++
    gcc
  ];
}
