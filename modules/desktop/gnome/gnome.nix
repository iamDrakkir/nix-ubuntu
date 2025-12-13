{ config, lib, pkgs, ... }:
{
  imports = [
    ./pop-shell.nix
  ];

  config = lib.mkIf config.myConfig.desktop.gnome.enable {
    # GNOME-related packages
    home.packages = with pkgs; [
      # GNOME Extensions and tools
      gnome-shell-extensions
      gnome-browser-connector
      # GNOME Extensions app for configuring extensions
      gnome-extension-manager
    ];

    # Enable GNOME extensions program
    programs.gnome-shell = {
      enable = true;
      extensions = [
        # { package = pkgs.gnomeExtensions.forge; }
        { package = pkgs.gnomeExtensions.pop-shell; }
      ];
    };

    # GNOME keybindings and dconf configuration
    dconf.settings = {
    "org/gnome/desktop/wm/keybindings" = {
      close = [ "<Super>q" ];
      # Pop-shell uses Super+f for fullscreen, not maximize  
      toggle-fullscreen = [ "<Super>f" ];
      # Disable show-desktop to prevent conflict with Discord shortcut
      show-desktop = [ ];
      # DISABLED - Let pop-shell.nix handle all workspace management
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
      # DISABLED - Let pop-shell.nix handle window movement
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

    # Configure workspaces and mutter for pop-shell
    "org/gnome/mutter" = {
      dynamic-workspaces = false;
      num-workspaces = 10;
      # Disable edge-tiling as pop-shell manages tiling
      edge-tiling = false;
      # Disable center-new-windows as pop-shell manages placement
      center-new-windows = false;
    };

    "org/gnome/desktop/wm/preferences" = {
      num-workspaces = 10;
      # Use click focus mode - works better with tiling
      focus-mode = "sloppy";
      auto-raise = false;
    };

    # Mouse settings
    "org/gnome/desktop/peripherals/mouse" = {
      accel-profile = "flat";
      speed = 0.5;
    };

    # Completely disable the dock
    "org/gnome/shell/extensions/dash-to-dock" = {
      dock-fixed = false;
      autohide = false;
      intellihide = false;
      # Move dock off-screen or make it invisible
      dock-position = "BOTTOM";
      extend-height = false;
      transparency-mode = "FIXED";
      background-opacity = 0.0;
      # Disable all dock functionality
      show-favorites = false;
      show-running = false;
      show-show-apps-button = false;
      show-mounts = false;
      show-trash = false;
      # Disable all dash-to-dock hotkeys to prevent conflicts
      app-hotkey-1 = [ ];
      app-hotkey-2 = [ ];
      app-hotkey-3 = [ ];
      app-hotkey-4 = [ ];
      app-hotkey-5 = [ ];
      app-hotkey-6 = [ ];
      app-hotkey-7 = [ ];
      app-hotkey-8 = [ ];
      app-hotkey-9 = [ ];
      app-hotkey-10 = [ ];
      app-ctrl-hotkey-1 = [ ];
      app-ctrl-hotkey-2 = [ ];
      app-ctrl-hotkey-3 = [ ];
      app-ctrl-hotkey-4 = [ ];
      app-ctrl-hotkey-5 = [ ];
      app-ctrl-hotkey-6 = [ ];
      app-ctrl-hotkey-7 = [ ];
      app-ctrl-hotkey-8 = [ ];
      app-ctrl-hotkey-9 = [ ];
      app-ctrl-hotkey-10 = [ ];
      app-shift-hotkey-1 = [ ];
      app-shift-hotkey-2 = [ ];
      app-shift-hotkey-3 = [ ];
      app-shift-hotkey-4 = [ ];
      app-shift-hotkey-5 = [ ];
      app-shift-hotkey-6 = [ ];
      app-shift-hotkey-7 = [ ];
      app-shift-hotkey-8 = [ ];
      app-shift-hotkey-9 = [ ];
      app-shift-hotkey-10 = [ ];
    };

    # Configure GNOME Shell extensions
    "org/gnome/shell" = {
      disabled-extensions = [
        "ubuntu-dock@ubuntu.com"
        "desktop-icons@csoriano"
        "ding@rastersoft.com"
        "tiling-assistant@ubuntu.com"
      ];
      disable-user-extensions = false;
    };

    # Disable GNOME shell application switching keybindings
    "org/gnome/shell/keybindings" = {
      switch-to-application-1 = [ ];
      switch-to-application-2 = [ ];
      switch-to-application-3 = [ ];
      switch-to-application-4 = [ ];
      switch-to-application-5 = [ ];
      switch-to-application-6 = [ ];
      switch-to-application-7 = [ ];
      switch-to-application-8 = [ ];
      switch-to-application-9 = [ ];
      open-application-menu = [ ];
      toggle-overview = [ ];
    };

    # Custom keybindings
    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/"
      ];
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      binding = "<Super>b";
      command = "zen";
      name = "Open Zen Browser";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
      binding = "<Super>Return";
      command = "ghostty";
      name = "Open Ghostty Terminal";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" = {
      binding = "<Super>space";
      command = "walker";
      name = "Open Walker Launcher";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3" = {
      binding = "<Super>d";
      command = "discord";
      name = "Open Discord";
    };

    # Disable desktop icons completely
    "org/gnome/desktop/background" = {
      show-desktop-icons = false;
    };

    "org/gnome/nautilus/desktop" = {
      # Disable all desktop icons in Nautilus
      home-icon-visible = false;
      network-icon-visible = false;
      trash-icon-visible = false;
      volumes-visible = false;
    };

    # Dark theme configuration
    "org/gnome/desktop/interface" = {
      gtk-theme = "Adwaita-dark";
      icon-theme = "Adwaita";
      cursor-theme = "Adwaita";
      color-scheme = "prefer-dark";
      # Better font rendering
      font-antialiasing = "rgba";
      font-hinting = "slight";
      # Show battery percentage in top bar
      show-battery-percentage = true;
      enable-hot-corners = false;
      # Clock format
      clock-show-seconds = false;
      clock-show-weekday = true;
      # Disable automatic screen rotation
      gtk-enable-primary-paste = false;
    };

    # Privacy settings
    "org/gnome/desktop/privacy" = {
      # Disable usage statistics
      report-technical-problems = false;
      # Don't remember recent files
      remember-recent-files = false;
      # Disable location services
      disable-camera = false;
      disable-microphone = false;
    };

    # Power management
    "org/gnome/settings-daemon/plugins/power" = {
      # Don't suspend when lid is closed on AC power
      lid-close-ac-action = "nothing";
      # Dim screen when idle
      idle-dim = true;
      # Sleep timeout (in seconds) - 30 minutes
      sleep-inactive-ac-timeout = 1800;
      sleep-inactive-battery-timeout = 900; # 15 minutes on battery
      # Screen blanking timeout (0 = never)
      sleep-inactive-ac-type = "nothing";
      sleep-inactive-battery-type = "suspend";
    };

    # Session preferences
    "org/gnome/desktop/session" = {
      # Idle delay before screen locks (in seconds)
      idle-delay = 1800; # 30 minutes before screen dims/locks
    };

    # Remove logout/shutdown confirmation delay
    "org/gnome/SessionManager" = {
      logout-prompt = false;
    };

    # Screen saver / screen blanking settings
    "org/gnome/desktop/screensaver" = {
      # Disable automatic lock screen
      lock-enabled = false;
      # Time before lock screen activates after idle (if enabled)
      lock-delay = 1800; # 30 minutes
      # Disable screen blanking entirely - set to 0 for never
      idle-activation-enabled = false;
    };

    # Sound settings
    "org/gnome/desktop/sound" = {
      # Disable event sounds
      event-sounds = false;
      # Keep input/output sounds
      input-feedback-sounds = false;
    };

    # File manager (Nautilus) settings
    "org/gnome/nautilus/preferences" = {
      # Always show hidden files
      show-hidden-files = true;
      # Show file tree sidebar
      sidebar-width = 200;
      # Default view
      default-folder-viewer = "list-view";
      # Show file extensions
      show-create-link = true;
    };

    # Top bar and interface configuration  
    "org/gnome/shell/extensions/user-theme" = {
      # If you want to use custom shell themes
      name = "";
    };

    # Keyboard settings
    "org/gnome/desktop/peripherals/keyboard" = {
      # Key repeat settings for better typing
      delay = 100;
      repeat-interval = 10;
    };

    # Touchpad settings (if applicable)
    "org/gnome/desktop/peripherals/touchpad" = {
      # Enable tap to click
      tap-to-click = true;
      # Natural scrolling (like macOS)
      natural-scroll = false;
      # Two finger right click
      click-method = "fingers";
      # Disable while typing
      disable-while-typing = true;
    };
  };
  };
}
