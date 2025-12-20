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

    # ========== Pretty Symlink Helpers ==========
    # Based on: https://blog.daniel-beskin.com/2025-10-18-symlinking-home-manager
    # These helpers provide a DRY way to create out-of-store symlinks with home-manager

    symlink = {
      inherit (lib) # TODO: is this import necessary now that we refer to them with lib. ?
        flatten
        map
        mergeAttrsList
        ;

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
      # pathTransform: optional function to transform name to source path (default: identity)
      mkHelpers =
        config: sourceRoot: pathTransform:
        let
          inherit (config.lib.file) mkOutOfStoreSymlink;
          pipe = lib.flip lib.pipe;
          transform = if pathTransform != null then pathTransform else (name: name);
        in
        rec {
          # Create a symlink source path by appending to sourceRoot
          # Usage: toSourcePath "nvim"
          toSourcePath = name: "${sourceRoot}/${transform name}";

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
              # Don't use recursive with out-of-store symlinks - just symlink the whole directory
              # recursive = true; # TODO: is it true that we should not use recursive here?
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
      # Handles the typical ~/.dotfiles/<name>/.config/<name> -> ~/.config/<name> pattern
      # Usage: mkDotfilesLinks config homeDirectory ["nvim" "rofi" "lazygit"]
      mkDotfilesLinks =
        config: homeDirectory: names:
        let
          inherit (lib) last splitString;
          # Extract base name from .config/name -> name
          baseName = path: last (splitString "/" path);
          # Transform: .config/nvim -> nvim/.config/nvim
          dotfileTransform = name: "${baseName name}/${name}";
          # Create helpers with the dotfiles root and transform
          helpers = symlink.mkHelpers config "${homeDirectory}/.dotfiles" dotfileTransform;
          # Prepend .config/ to each name
          confPaths = lib.map (name: ".config/${name}") names;
        in
        symlink.flatMerge [ (helpers.linkConfDirs confPaths) ];
    };
  };
}
