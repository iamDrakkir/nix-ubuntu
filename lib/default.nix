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

    # Helper to check if running on specific host
    # Usage: lib.custom.isHost "terra"
    isHost = hostname: getHostname == hostname;

    # Helper for conditional imports based on hostname
    # Usage: lib.custom.importForHost "terra" ./terra-config.nix
    importForHost = hostname: path: if isHost hostname then path else null;

    # ========== Electron App Wrapper ==========
    # Wraps Electron apps to run with --no-sandbox flag
    # Usage: lib.custom.wrapElectronApp pkgs pkgs.discord "discord"
    wrapElectronApp =
      pkgs: app: name:
      pkgs.writeShellScriptBin name ''
        exec ${app}/bin/${name} --no-sandbox "$@"
      '';

    # ========== Pretty Symlink Helpers ==========
    # Based on: https://blog.daniel-beskin.com/2025-10-18-symlinking-home-manager
    # These helpers provide a DRY way to create out-of-store symlinks with home-manager

    symlink = {
      # Flipped pipe for composing functions left-to-right
      # Usage: pipe [func1 func2 func3] value
      pipe = lib.flip lib.pipe;

      # Flatten a list of attribute sets and merge them
      # Usage: flatMerge [[{a=1;}] [{b=2;}]]
      flatMerge = lib.flip lib.pipe [
        lib.flatten
        lib.mergeAttrsList
      ];

      # Create out-of-store symlink helpers
      # config: home-manager config object (for mkOutOfStoreSymlink)
      # sourceRoot: absolute path to source directory
      mkHelpers =
        config: sourceRoot:
        let
          inherit (config.lib.file) mkOutOfStoreSymlink;
          pipe = lib.flip lib.pipe;
        in
        rec {
          # Create a symlink source path by appending to sourceRoot
          # Usage: toSourcePath "nvim"
          toSourcePath = name: "${sourceRoot}/${name}";

          # Create out-of-store symlink
          # Usage: link "nvim"
          link = pipe [
            toSourcePath
            mkOutOfStoreSymlink
          ];

          # Link a single file to home.file
          # Usage: linkFile "path/to/file"
          linkFile = name: { ${name}.source = link name; };

          # Link a directory recursively to home.file
          # Usage: linkDir "path/to/dir"
          linkDir = name: {
            ${name} = {
              source = link name;
              # Note: recursive = true should NOT be used with out-of-store symlinks
              # We symlink the whole directory, not its contents
            };
          };

          # Map linkFile over a list of names
          # Usage: linkConfFiles ["file1" "file2"]
          linkConfFiles = lib.map linkFile;

          # Map linkDir over a list of names
          # Usage: linkConfDirs ["dir1" "dir2"]
          linkConfDirs = lib.map linkDir;

          # Convenience function to link multiple files and directories
          # Usage: linkAll { files = ["file1"]; dirs = ["dir1" "dir2"]; }
          linkAll =
            {
              files ? [ ],
              dirs ? [ ],
            }:
            pipe
              [
                lib.flatten
                lib.mergeAttrsList
              ]
              [
                (linkConfFiles files)
                (linkConfDirs dirs)
              ];
        };

      # High-level helper for common dotfiles pattern
      # Links dotfiles/<name> -> ~/.config/<name>
      # Usage: mkDotfilesLinks config ["nvim" "rofi" "lazygit"]
      mkDotfilesLinks =
        config: names:
        let
          # Get the flake root directory (where the dotfiles folder is)
          flakeRoot = config.home.homeDirectory + "/.config/nix";
          # Create helpers with the dotfiles root
          helpers = symlink.mkHelpers config "${flakeRoot}/dotfiles";
          # Prepend .config/ to each name for home.file attribute paths
          confPaths = lib.map (name: ".config/${name}") names;
        in
        # linkConfDirs expects the name as it appears in dotfiles/, not with .config/ prefix
        # So we need to pass the original names, not confPaths
        lib.listToAttrs (
          lib.imap0 (i: name: {
            name = ".config/${name}";
            value.source = helpers.link name;
          }) names
        );
    };
  };
}
