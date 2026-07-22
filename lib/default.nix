{ lib, ... }:

{
  # Custom library functions for easier imports and organization
  # Following EmergentMind's pattern for readable import paths
  custom = rec {
    # Helper to get hostname (attempts to read from /etc/hostname)
    # Usage: lib.custom.getHostname
    getHostname =
      if builtins.pathExists /etc/hostname then
        lib.strings.removeSuffix "\n" (builtins.readFile /etc/hostname)
      else
        "unknown";

    # Helper for conditional imports based on hostname
    # Usage: lib.custom.importForHost "terra" ./terra-config.nix
    importForHost = hostname: path: if isHost hostname then path else null;
    # Helper to check if running on specific host
    # Usage: lib.custom.isHost "terra"
    isHost = hostname: getHostname == hostname;

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
        link = config: src: config.lib.file.mkOutOfStoreSymlink "${dotfilesRoot config}/${src}";

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
