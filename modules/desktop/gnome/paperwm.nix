{ pkgs, ... }:
{
  # PaperWM-specific packages
  home.packages = with pkgs; [
    gnomeExtensions.paperwm
  ];

  # Enable PaperWM extension
  programs.gnome-shell = {
    enable = true;
    extensions = [
      { package = pkgs.gnomeExtensions.paperwm; }
    ];
  };

  # PaperWM-specific GNOME configuration
  dconf.settings = {
    "org/gnome/desktop/wm/keybindings" = {
      close = [ "<Super>q" ];
      toggle-maximized = [ "<Super>f" ];
      toggle-fullscreen = [ "<Super><Shift>f" ];
      # Workspace switching - DISABLED for paperWM compatibility
      # paperWM uses Super+Number for window navigation within workspaces
      # switch-to-workspace-1 = [ "<Super>1" ];
      # switch-to-workspace-2 = [ "<Super>2" ];
      # switch-to-workspace-3 = [ "<Super>3" ];
      # switch-to-workspace-4 = [ "<Super>4" ];
      # switch-to-workspace-5 = [ "<Super>5" ];
      # switch-to-workspace-6 = [ "<Super>6" ];
      # switch-to-workspace-7 = [ "<Super>7" ];
      # switch-to-workspace-8 = [ "<Super>8" ];
      # switch-to-workspace-9 = [ "<Super>9" ];
      # switch-to-workspace-10 = [ "<Super>0" ];
      # Move window to workspace - DISABLED for paperWM compatibility
      # move-to-workspace-1 = [ "<Super><Shift>1" ];
      # move-to-workspace-2 = [ "<Super><Shift>2" ];
      # move-to-workspace-3 = [ "<Super><Shift>3" ];
      # move-to-workspace-4 = [ "<Super><Shift>4" ];
      # move-to-workspace-5 = [ "<Super><Shift>5" ];
      # move-to-workspace-6 = [ "<Super><Shift>6" ];
      # move-to-workspace-7 = [ "<Super><Shift>7" ];
      # move-to-workspace-8 = [ "<Super><Shift>8" ];
      # move-to-workspace-9 = [ "<Super><Shift>9" ];
      # move-to-workspace-10 = [ "<Super><Shift>0" ];
      # Disable Super+Space for input source switching to free it up for Walker
      switch-input-source = [ "XF86Keyboard" ];
      switch-input-source-backward = [ "<Shift>XF86Keyboard" ];
    };
    
    # Configure workspaces for PaperWM
    "org/gnome/mutter" = {
      dynamic-workspaces = false;
      num-workspaces = 10;
      # Disable edge-tiling as it conflicts with paperWM
      edge-tiling = false;
      # Disable center-new-windows as paperWM manages window placement
      center-new-windows = false;
    };
    
    "org/gnome/desktop/wm/preferences" = {
      num-workspaces = 10;
      # Use click focus mode - works better with paperWM
      focus-mode = "click";
      auto-raise = false;
    };
    
    # Configure GNOME Shell extensions for PaperWM
    "org/gnome/shell" = {
      enabled-extensions = [
        pkgs.gnomeExtensions.paperwm.extensionUuid
      ];
    };
    
    # PaperWM configuration
    "org/gnome/shell/extensions/paperwm" = {
      # Enable paperWM by default on all workspaces
      only-scratch-in-overview = true;
      # Disable animations for better performance
      animation-time = 0.1;
      # Window gap settings
      window-gap = 8;
      vertical-margin = 8;
      horizontal-margin = 8;
      # Disable top bar styling modifications
      disable-topbar-styling = true;
      # Remove desktop items/icons
      show-desktop-icons = false;
      # Disable desktop workspace if it exists
      show-workspace-indicator = false;
    };
  };
}