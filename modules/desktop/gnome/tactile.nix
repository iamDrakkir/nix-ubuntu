{ pkgs, ... }:
{
  # Tactile-specific packages
  home.packages = with pkgs; [
    gnomeExtensions.tactile
  ];

  # Enable Tactile extension
  programs.gnome-shell = {
    enable = true;
    extensions = [
      { package = pkgs.gnomeExtensions.tactile; }
    ];
  };

  # Tactile-optimized GNOME configuration
  dconf.settings = {
    "org/gnome/desktop/wm/keybindings" = {
      close = [ "<Super>q" ];
      toggle-maximized = [ "<Super>f" ];
      toggle-fullscreen = [ "<Super><Shift>f" ];
      # Enable workspace switching - works well with Tactile
      switch-to-workspace-1 = [ "<Super>1" ];
      switch-to-workspace-2 = [ "<Super>2" ];
      switch-to-workspace-3 = [ "<Super>3" ];
      switch-to-workspace-4 = [ "<Super>4" ];
      switch-to-workspace-5 = [ "<Super>5" ];
      switch-to-workspace-6 = [ "<Super>6" ];
      switch-to-workspace-7 = [ "<Super>7" ];
      switch-to-workspace-8 = [ "<Super>8" ];
      switch-to-workspace-9 = [ "<Super>9" ];
      switch-to-workspace-10 = [ "<Super>0" ];
      # Move window to workspace
      move-to-workspace-1 = [ "<Super><Shift>1" ];
      move-to-workspace-2 = [ "<Super><Shift>2" ];
      move-to-workspace-3 = [ "<Super><Shift>3" ];
      move-to-workspace-4 = [ "<Super><Shift>4" ];
      move-to-workspace-5 = [ "<Super><Shift>5" ];
      move-to-workspace-6 = [ "<Super><Shift>6" ];
      move-to-workspace-7 = [ "<Super><Shift>7" ];
      move-to-workspace-8 = [ "<Super><Shift>8" ];
      move-to-workspace-9 = [ "<Super><Shift>9" ];
      move-to-workspace-10 = [ "<Super><Shift>0" ];
      # Disable Super+Space for input source switching to free it up for Walker
      switch-input-source = [ "XF86Keyboard" ];
      switch-input-source-backward = [ "<Shift>XF86Keyboard" ];
    };

    # Configure workspaces for Tactile
    "org/gnome/mutter" = {
      dynamic-workspaces = false;
      num-workspaces = 10;
      # Enable edge-tiling 
      edge-tiling = true;
      # Allow center-new-windows 
      center-new-windows = false;
    };

    "org/gnome/desktop/wm/preferences" = {
      num-workspaces = 10;
      # Use click focus mode for better control
      focus-mode = "click";
      auto-raise = false;
    };

    # Configure GNOME Shell extensions for Tactile
    "org/gnome/shell" = {
      enabled-extensions = [
        pkgs.gnomeExtensions.tactile.extensionUuid
      ];
    };

    # Tactile configuration
    "org/gnome/shell/extensions/tactile" = {
      # Grid size (4x4 grid by default)
      col-count = 4;
      row-count = 4;

      # Gap settings
      gap-size = 8;

      # Show grid on Super+T
      show-grid-on-primary-display = true;

      # Animation settings
      animation-duration = 200;

      # Window behavior
      maximize-difference-threshold = 24;

      # Grid appearance
      grid-opacity = 90;

      # Keyboard shortcuts (Super+T is default to show grid)
      # After showing grid, type two tiles (or same tile twice) to position window
    };
  };
}
