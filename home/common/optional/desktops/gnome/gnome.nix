{
  lib,
  config,
  pkgs,
  ...
}:
let
  cursorSize = lib.toInt config.home.sessionVariables.CURSOR_SIZE;
  cursorTheme = config.home.sessionVariables.CURSOR_THEME;
in
{
  # GNOME dconf configuration
  dconf.settings = {
    "org/gnome/SessionManager" = {
      logout-prompt = false;
    };

    "org/gnome/desktop/background" = {
      show-desktop-icons = false;
    };

    "org/gnome/desktop/interface" = {
      clock-show-seconds = false;
      clock-show-weekday = true;
      color-scheme = "prefer-dark";
      cursor-size = cursorSize;
      cursor-theme = cursorTheme;
      enable-hot-corners = false;
      font-antialiasing = "rgba";
      font-hinting = "slight";
      gtk-enable-primary-paste = false;
      gtk-theme = "Adwaita-dark";
      icon-theme = "Adwaita";
      show-battery-percentage = true;
    };

    "org/gnome/desktop/peripherals/keyboard" = {
      delay = 100;
      repeat-interval = 10;
    };

    "org/gnome/desktop/peripherals/mouse" = {
      accel-profile = "flat";
      speed = 0.5;
    };

    "org/gnome/desktop/peripherals/touchpad" = {
      click-method = "fingers";
      disable-while-typing = true;
      natural-scroll = false;
      tap-to-click = true;
    };

    "org/gnome/desktop/privacy" = {
      disable-camera = false;
      disable-microphone = false;
      remember-recent-files = false;
      report-technical-problems = false;
    };

    "org/gnome/desktop/screensaver" = {
      idle-activation-enabled = false;
      lock-delay = 1800;
      lock-enabled = false;
    };

    "org/gnome/desktop/session" = {
      idle-delay = lib.hm.gvariant.mkUint32 900; # 15 minutes before screen blanks
    };

    "org/gnome/desktop/sound" = {
      event-sounds = false;
      input-feedback-sounds = false;
    };

    "org/gnome/desktop/wm/keybindings" = {
      # Move window to workspace
      move-to-workspace-1 = [ "<Super><Shift>1" ];
      move-to-workspace-10 = [ "<Super><Shift>0" ];
      move-to-workspace-2 = [ "<Super><Shift>2" ];
      move-to-workspace-3 = [ "<Super><Shift>3" ];
      move-to-workspace-4 = [ "<Super><Shift>4" ];
      move-to-workspace-5 = [ "<Super><Shift>5" ];
      move-to-workspace-6 = [ "<Super><Shift>6" ];
      move-to-workspace-7 = [ "<Super><Shift>7" ];
      move-to-workspace-8 = [ "<Super><Shift>8" ];
      move-to-workspace-9 = [ "<Super><Shift>9" ];
      show-desktop = [ ];
      switch-input-source = [ "XF86Keyboard" ];
      switch-input-source-backward = [ "<Shift>XF86Keyboard" ];
      # Workspace switching
      switch-to-workspace-1 = [ "<Super>1" ];
      switch-to-workspace-10 = [ "<Super>0" ];
      switch-to-workspace-2 = [ "<Super>2" ];
      switch-to-workspace-3 = [ "<Super>3" ];
      switch-to-workspace-4 = [ "<Super>4" ];
      switch-to-workspace-5 = [ "<Super>5" ];
      switch-to-workspace-6 = [ "<Super>6" ];
      switch-to-workspace-7 = [ "<Super>7" ];
      switch-to-workspace-8 = [ "<Super>8" ];
      switch-to-workspace-9 = [ "<Super>9" ];
    };

    "org/gnome/desktop/wm/preferences" = {
      auto-raise = false;
      focus-mode = "sloppy";
      num-workspaces = 10;
    };

    "org/gnome/mutter" = {
      center-new-windows = false;
      dynamic-workspaces = false;
      edge-tiling = false;
      num-workspaces = 10;
    };

    "org/gnome/nautilus/desktop" = {
      home-icon-visible = false;
      network-icon-visible = false;
      trash-icon-visible = false;
      volumes-visible = false;
    };

    "org/gnome/nautilus/preferences" = {
      default-folder-viewer = "list-view";
      show-create-link = true;
      show-hidden-files = true;
      sidebar-width = 200;
    };

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
      command = "zen-beta";
      name = "Open Zen Browser";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
      binding = "<Super>Return";
      command = "env GTK_IM_MODULE=simple ghostty";
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

    "org/gnome/settings-daemon/plugins/power" = {
      idle-dim = true;
      lid-close-ac-action = "nothing";
      sleep-inactive-ac-timeout = 1800;
      sleep-inactive-ac-type = "nothing";
      sleep-inactive-battery-timeout = 900;
      sleep-inactive-battery-type = "suspend";
    };

    "org/gnome/shell" = {
      disable-user-extensions = false;

      disabled-extensions = [
        "ubuntu-dock@ubuntu.com"
        "desktop-icons@csoriano"
        "ding@rastersoft.com"
        "tiling-assistant@ubuntu.com"
      ];
    };

    "org/gnome/shell/extensions/dash-to-dock" = {
      autohide = false;
      background-opacity = 0.0;
      dock-fixed = false;
      dock-position = "BOTTOM";
      extend-height = false;
      intellihide = false;
      show-favorites = false;
      show-mounts = false;
      show-running = false;
      show-show-apps-button = false;
      show-trash = false;
      transparency-mode = "FIXED";
    };

    "org/gnome/shell/extensions/user-theme" = {
      name = "";
    };

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
    };
  };

  # GNOME-related packages
  home.packages = with pkgs; [
    gnome-shell-extensions
    gnome-browser-connector
    gnome-extension-manager

    # Launcher for the Super+Space bind below. GNOME runs its own shell, so
    # Noctalia (which the other compositors spawn at startup) is not running
    # here and cannot provide the launcher.
    walker
  ];

  imports = [
    ./pop-shell.nix
  ];
}
