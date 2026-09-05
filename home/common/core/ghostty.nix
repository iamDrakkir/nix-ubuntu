{
  lib,
  config,
  pkgs,
  ...
}:

{
  programs.ghostty = {
    enable = true;

    settings = {
      # Default shell
      command = "fish";
      # Behavior
      confirm-close-surface = false;
      # Custom shader
      custom-shader = "shaders/cursor_warp.glsl";

      # Font configuration
      font-feature = [
        "-liga"
        "-calt"
        "-dlig"
      ];

      # Window decoration
      gtk-titlebar = false;
      # Mouse
      mouse-scroll-multiplier = 0.5;
      # Theme
      theme = "noctalia";
      window-decoration = false;
    };
  };

  xdg = {
    # Symlink shader from dotfiles repo (out-of-store, edits apply without rebuild)
    configFile = lib.custom.symlink.mkXdgConfigLinks config [
      "ghostty/shaders/cursor_warp.glsl"
    ];

    # Override desktop entry to fix dead keys on GTK 4.20+ / Wayland
    # See: https://github.com/ghostty-org/ghostty/discussions/8899
    desktopEntries.com-mitchellh-ghostty = {
      categories = [
        "System"
        "TerminalEmulator"
      ];

      comment = "A fast, feature-rich, and cross-platform terminal emulator";
      exec = "env GTK_IM_MODULE=simple ghostty %U";
      icon = "com.mitchellh.ghostty";
      name = "Ghostty";

      settings = {
        Keywords = "terminal;tty;pty;";
      };

      startupNotify = true;
      type = "Application";
    };
  };
}
