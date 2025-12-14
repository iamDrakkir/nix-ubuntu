{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.desktop.gnome.enable {
    # Enable Pop Shell extension
    programs.gnome-shell = {
      enable = true;
      extensions = [
        { package = pkgs.gnomeExtensions.pop-shell; }
      ];
    };

    dconf.settings = {
      "org/gnome/desktop/wm/keybindings" = {
        close = [ "<Super>q" "<Alt>F4" ];
        minimize = [ "<Super>comma" ];
        toggle-maximized = [ "<Super>f" ];
        toggle-fullscreen = [ "<Super><Shift>f" ];
        move-to-monitor-left = [ ];
        move-to-monitor-right = [ ];
        move-to-monitor-up = [ ];
        move-to-monitor-down = [ ];
        move-to-workspace-down = [ ];
        move-to-workspace-up = [ ];
        switch-to-workspace-down = [ "<Primary><Super>Down" ];
        switch-to-workspace-up = [ "<Primary><Super>Up" ];
        switch-to-workspace-left = [ ];
        switch-to-workspace-right = [ ];
        maximize = [ ];
        unmaximize = [ ];
      };

      "org/gnome/shell/keybindings" = {
        open-application-menu = [ ];
        toggle-message-tray = [ "<Super>v" ];
        toggle-overview = [ ];
      };

      "org/gnome/mutter/keybindings" = {
        toggle-tiled-left = [ ];
        toggle-tiled-right = [ ];
      };

      "org/gnome/mutter/wayland/keybindings" = {
        restore-shortcuts = [ ];
      };

      "org/gnome/shell/extensions/pop-shell" = {
        toggle-tiling = [ "<Super>y" ];
        toggle-floating = [ "<Super>g" ];
        tile-enter = [ "<Super>t" ];
        tile-accept = [ "Return" ];
        tile-reject = [ "Escape" ];
        toggle-stacking-global = [ "<Super>s" ];
        pop-workspace-down = [ "<Shift><Super>Down" "<Shift><Super>j" ];
        pop-workspace-up = [ "<Shift><Super>Up" "<Shift><Super>k" ];
        pop-monitor-left = [ "<Shift><Super>Left" "<Shift><Super>h" ];
        pop-monitor-right = [ "<Shift><Super>Right" "<Shift><Super>l" ];
        pop-monitor-down = [ ];
        pop-monitor-up = [ ];
        focus-left = [ "<Super>Left" "<Super>h" ];
        focus-down = [ "<Super>Down" "<Super>j" ];
        focus-up = [ "<Super>Up" "<Super>k" ];
        focus-right = [ "<Super>Right" "<Super>l" ];
        tile-by-default = true;
        mouse-cursor-follows-active-window = true;
        mouse-cursor-focus-location = 0;
        gap-inner = 8;
        gap-outer = 8;
        smart-gaps = true;
        snap-to-grid = true;
        active-hint = true;
        active-hint-border-radius = 2;
        show-title = false;
        hint-color-rgba = "rgba(108, 196, 251, 1)";
      };
      "org/gnome/shell" = {
        enabled-extensions = [
          pkgs.gnomeExtensions.pop-shell.extensionUuid
        ];
      };
    };
  };
}
