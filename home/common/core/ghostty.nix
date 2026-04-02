{ config, pkgs, ... }:

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
      theme = "noctalia";

      # Behavior
      confirm-close-surface = false;

      # Custom shader
      custom-shader = "shaders/cursor_warp.glsl";

      # Default shell
      command = "fish";
    };
  };

  # Override desktop entry to fix dead keys on GTK 4.20+ / Wayland
  # See: https://github.com/ghostty-org/ghostty/discussions/8899
  xdg.desktopEntries.com-mitchellh-ghostty = {
    name = "Ghostty";
    comment = "A fast, feature-rich, and cross-platform terminal emulator";
    exec = "env GTK_IM_MODULE=simple ghostty %U";
    icon = "com.mitchellh.ghostty";
    type = "Application";
    categories = [
      "System"
      "TerminalEmulator"
    ];
    startupNotify = true;
    settings = {
      Keywords = "terminal;tty;pty;";
    };
  };

  # Copy shader files to config directory
  xdg.configFile."ghostty/shaders/cursor_warp.glsl".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/nix/dotfiles/ghostty/shaders/cursor_warp.glsl";
}
