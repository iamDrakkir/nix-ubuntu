{
  lib,
  config,
  pkgs,
  ...
}:

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

    # Go (needed to build herdr plugins from source)
    go

    # C/C++
    gcc
  ];

  programs = {
    # AI agent multiplexer.
    #
    # `settings` is deliberately left empty so the upstream module does not take
    # ownership of config.toml. Herdr rewrites that file itself (onboarding flag)
    # and Noctalia's templates write the theme block into it, so a read-only store
    # symlink would both break them and fail activation. Out-of-store symlink it to
    # the repo instead, matching how noctalia/settings.toml is handled.
    herdr = {
      enable = true;
      package = pkgs.herdr;
    };

    nix-index-database.comma.enable = true;
  };

  xdg.configFile."herdr/config.toml".source = lib.custom.symlink.link config "herdr/config.toml";
}
