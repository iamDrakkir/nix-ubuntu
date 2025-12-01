{ pkgs, ... }:
{
  # Tiling Shell-specific packages
  home.packages = with pkgs; [
    gnomeExtensions.tiling-shell
  ];

  # Enable Tiling Shell extension
  programs.gnome-shell = {
    enable = true;
    extensions = [
      { package = pkgs.gnomeExtensions.tiling-shell; }
    ];
  };

  # Tiling Shell-optimized GNOME configuration
  dconf.settings = {
    "org/gnome/desktop/wm/keybindings" = {
      close = [ "<Super>q" ];
      toggle-maximized = [ "<Super>f" ];
      toggle-fullscreen = [ "<Super><Shift>f" ];
      # Enable workspace switching - works well with Tiling Shell
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
    
    # Configure workspaces for Tiling Shell
    "org/gnome/mutter" = {
      dynamic-workspaces = false;
      num-workspaces = 10;
      # Enable edge-tiling - works well with Tiling Shell
      edge-tiling = true;
      # Allow center-new-windows 
      center-new-windows = true;
    };
    
    "org/gnome/desktop/wm/preferences" = {
      num-workspaces = 10;
      # Use sloppy focus mode - works well with tiling
      focus-mode = "sloppy";
      auto-raise = false;
    };
    
    # Configure GNOME Shell extensions for Tiling Shell
    "org/gnome/shell" = {
      enabled-extensions = [
        pkgs.gnomeExtensions.tiling-shell.extensionUuid
      ];
    };
    
    # Tiling Shell configuration
    "org/gnome/shell/extensions/tilingshell" = {
      # Enable the tiling system (hold CTRL while moving)
      enable-tiling-system = true;
      
      # Enable automatic tiling for new windows
      enable-autotiling = true;
      
      # Gap settings
      inner-gaps = 8;
      outer-gaps = 8;
      
      # Snap assistant settings
      enable-snap-assist = true;
      snap-assistant-threshold = 54;
      
      # Enable keyboard shortcuts for window movement
      enable-move-keybindings = true;
      
      # Enable spanning multiple tiles with ALT
      enable-span-multiple-tiles = true;
      
      # Window management
      restore-window-original-size = true;
      resize-complementing-windows = true;
      enable-wraparound-focus = true;
      
      # Screen edge features
      active-screen-edges = true;
      top-edge-maximize = false;
      
      # Animation settings
      snap-assistant-animation-time = 180;
      tile-preview-animation-time = 100;
      
      # Window suggestions for better tiling
      enable-tiling-system-windows-suggestions = true;
      enable-snap-assistant-windows-suggestions = true;
      
      # UI settings
      show-indicator = true;
      override-window-menu = true;
    };
  };
}