{ lib, ... }:

{
  # Custom library functions for easier imports and organization.
  # Exposed as `lib.custom.*` (wired up in flake.nix via nixpkgs.lib.extend).
  # Add new shared helpers here rather than duplicating them across modules.
  #
  # NOTE: keep everything in here pure. Helpers that read host state at
  # eval time (e.g. builtins.readFile /etc/hostname) silently degrade under
  # pure evaluation and drop config with no error — pass `hostname` through
  # specialArgs instead, which flake.nix already does.
  custom = {
    # ========== Pretty Symlink Helpers ==========
    # Based on: https://blog.daniel-beskin.com/2025-10-18-symlinking-home-manager
    #
    # Out-of-store symlinks point HM-managed config files/dirs straight at the
    # live dotfiles repo, so edits apply without a rebuild. All paths are
    # relative to dotfiles/ (e.g. "nvim", "ghostty/shaders/cursor_warp.glsl").
    symlink =
      let
        dotfilesRoot = config: "${config.home.homeDirectory}/.config/nix/dotfiles";
      in
      rec {
        # Out-of-store symlink to dotfiles/<src>.
        link = config: src: config.lib.file.mkOutOfStoreSymlink (path config src);

        # General builder: map a list of `{ src; target; }` pairs into an
        # `xdg.configFile` attrset, linking dotfiles/<src> -> <target> (relative
        # to xdg.configHome). Use this when the dotfile path differs from the
        # target path.
        # Usage: xdg.configFile = mkLinks config [ { src = "foo/x"; target = "bar/x"; } ]
        mkLinks =
          config: entries:
          lib.listToAttrs (
            lib.map (
              { src, target }:
              {
                name = target;
                value.source = link config src;
              }
            ) entries
          );

        # Common case: link dotfiles/<src> -> $XDG_CONFIG_HOME/<src> for each src
        # (the dotfile path doubles as the target). Covers whole dirs and files.
        # Assign the result to `xdg.configFile`.
        # Usage: xdg.configFile = mkXdgConfigLinks config [
        #          "nvim" "noctalia/colors.json" "ghostty/shaders/cursor_warp.glsl"
        #        ];
        mkXdgConfigLinks =
          config: srcs:
          mkLinks config (
            lib.map (src: {
              inherit src;
              target = src;
            }) srcs
          );

        # Absolute path of dotfiles/<src> in the live repo, as a plain string.
        # Use when something needs the path itself rather than a symlink
        # (e.g. a wrapper script that execs a dotfiles script).
        path = config: src: "${dotfilesRoot config}/${src}";
      };

    # ========== Electron App Wrapper ==========
    # Wraps Electron apps to run with --no-sandbox flag
    # Usage: lib.custom.wrapElectronApp pkgs pkgs.discord "discord"
    wrapElectronApp =
      pkgs: app: name:
      pkgs.writeShellScriptBin name ''
        exec ${app}/bin/${name} --no-sandbox "$@"
      '';
  };
}
