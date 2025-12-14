{ config, lib, pkgs, ... }:
{
  imports = [
    ./pop-shell.nix
  ];

  config = lib.mkIf config.myConfig.desktop.gnome.enable {
    # GNOME-related packages
    home.packages = with pkgs; [
      gnome-shell-extensions
      gnome-browser-connector
      gnome-extension-manager
    ];

    # GNOME dconf configuration
    dconf.settings = {
      "org/gnome/desktop/wm/keybindings" = {
        show-desktop = [ ];
        switch-input-source = [ "XF86Keyboard" ];
        switch-input-source-backward = [ "<Shift>XF86Keyboard" ];
        # Workspace switching
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
      };

      "org/gnome/mutter" = {
        dynamic-workspaces = false;
        num-workspaces = 10;
        edge-tiling = false;
        center-new-windows = false;
      };

      "org/gnome/desktop/wm/preferences" = {
        num-workspaces = 10;
        focus-mode = "sloppy";
        auto-raise = false;
      };

      "org/gnome/desktop/peripherals/mouse" = {
        accel-profile = "flat";
        speed = 0.5;
      };

      "org/gnome/shell/extensions/dash-to-dock" = {
        dock-fixed = false;
        autohide = false;
        intellihide = false;
        dock-position = "BOTTOM";
        extend-height = false;
        transparency-mode = "FIXED";
        background-opacity = 0.0;
        show-favorites = false;
        show-running = false;
        show-show-apps-button = false;
        show-mounts = false;
        show-trash = false;
      };

      "org/gnome/shell" = {
        disabled-extensions = [
          "ubuntu-dock@ubuntu.com"
          "desktop-icons@csoriano"
          "ding@rastersoft.com"
          "tiling-assistant@ubuntu.com"
        ];
        disable-user-extensions = false;
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

      "org/gnome/desktop/background" = {
        show-desktop-icons = false;
      };

      "org/gnome/nautilus/desktop" = {
        home-icon-visible = false;
        network-icon-visible = false;
        trash-icon-visible = false;
        volumes-visible = false;
      };

      "org/gnome/desktop/interface" = {
        gtk-theme = "Adwaita-dark";
        icon-theme = "Adwaita";
        cursor-theme = "Adwaita";
        color-scheme = "prefer-dark";
        font-antialiasing = "rgba";
        font-hinting = "slight";
        show-battery-percentage = true;
        enable-hot-corners = false;
        clock-show-seconds = false;
        clock-show-weekday = true;
        gtk-enable-primary-paste = false;
      };

      "org/gnome/desktop/privacy" = {
        report-technical-problems = false;
        remember-recent-files = false;
        disable-camera = false;
        disable-microphone = false;
      };

      "org/gnome/settings-daemon/plugins/power" = {
        lid-close-ac-action = "nothing";
        idle-dim = true;
        sleep-inactive-ac-timeout = 1800;
        sleep-inactive-battery-timeout = 900;
        sleep-inactive-ac-type = "nothing";
        sleep-inactive-battery-type = "suspend";
      };

      "org/gnome/desktop/session" = {
        idle-delay = 1800;
      };

      "org/gnome/SessionManager" = {
        logout-prompt = false;
      };

      "org/gnome/desktop/screensaver" = {
        lock-enabled = false;
        lock-delay = 1800;
        idle-activation-enabled = false;
      };

      "org/gnome/desktop/sound" = {
        event-sounds = false;
        input-feedback-sounds = false;
      };

      "org/gnome/nautilus/preferences" = {
        show-hidden-files = true;
        sidebar-width = 200;
        default-folder-viewer = "list-view";
        show-create-link = true;
      };

      "org/gnome/shell/extensions/user-theme" = {
        name = "";
      };

      "org/gnome/desktop/peripherals/keyboard" = {
        delay = 100;
        repeat-interval = 10;
      };

      "org/gnome/desktop/peripherals/touchpad" = {
        tap-to-click = true;
        natural-scroll = false;
        click-method = "fingers";
        disable-while-typing = true;
      };
    };
  };
}
