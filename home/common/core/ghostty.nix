{ config, ... }:

{
  programs.ghostty = {
    enable = true;

    settings = {
      # Font configuration
      font-feature = [
        "-liga"
        "-calt"
        "-dlig"
      ];

      # Window decoration
      gtk-titlebar = false;
      window-decoration = false;

      # Theme
      theme = "Catppuccin Mocha";

      # Behavior
      confirm-close-surface = false;

      # Custom shader
      custom-shader = "shaders/cursor_warp.glsl";

      # Default shell
      command = "fish";
    };
  };

  # Copy shader files to config directory
  xdg.configFile."ghostty/shaders/cursor_warp.glsl".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/nix/dotfiles/ghostty/shaders/cursor_warp.glsl";
}
