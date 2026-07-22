{
  config,
  lib,
  pkgs,
  ...
}:
{
  dconf.settings = {
    "org/gnome/desktop/wm/keybindings" = {
      close = [
        "<Super>q"
        "<Alt>F4"
      ];
      maximize = [ ];
      minimize = [ "<Super>comma" ];
      move-to-monitor-down = [ ];
      move-to-monitor-left = [ ];
      move-to-monitor-right = [ ];
      move-to-monitor-up = [ ];
      move-to-workspace-down = [ ];
      move-to-workspace-up = [ ];
      switch-to-workspace-down = [ "<Primary><Super>Down" ];
      switch-to-workspace-left = [ ];
      switch-to-workspace-right = [ ];
      switch-to-workspace-up = [ "<Primary><Super>Up" ];
      toggle-fullscreen = [ "<Super><Shift>f" ];
      toggle-maximized = [ "<Super>f" ];
      unmaximize = [ ];
    };
    "org/gnome/mutter/keybindings" = {
      toggle-tiled-left = [ ];
      toggle-tiled-right = [ ];
    };
    "org/gnome/mutter/wayland/keybindings" = {
      restore-shortcuts = [ ];
    };
    "org/gnome/shell" = {
      enabled-extensions = [
        pkgs.gnomeExtensions.pop-shell.extensionUuid
      ];
    };
    "org/gnome/shell/extensions/pop-shell" = {
      active-hint = true;
      active-hint-border-radius = 2;
      focus-down = [
        "<Super>Down"
        "<Super>j"
      ];
      focus-left = [
        "<Super>Left"
        "<Super>h"
      ];
      focus-right = [
        "<Super>Right"
        "<Super>l"
      ];
      focus-up = [
        "<Super>Up"
        "<Super>k"
      ];
      gap-inner = 8;
      gap-outer = 8;
      hint-color-rgba = "rgba(108, 196, 251, 1)";
      mouse-cursor-focus-location = 0;
      mouse-cursor-follows-active-window = true;
      pop-monitor-down = [ ];
      pop-monitor-left = [
        "<Shift><Super>Left"
        "<Shift><Super>h"
      ];
      pop-monitor-right = [
        "<Shift><Super>Right"
        "<Shift><Super>l"
      ];
      pop-monitor-up = [ ];
      pop-workspace-down = [
        "<Shift><Super>Down"
        "<Shift><Super>j"
      ];
      pop-workspace-up = [
        "<Shift><Super>Up"
        "<Shift><Super>k"
      ];
      show-title = false;
      smart-gaps = true;
      snap-to-grid = true;
      tile-accept = [ "Return" ];
      tile-by-default = true;
      tile-enter = [ "<Super>t" ];
      tile-reject = [ "Escape" ];
      toggle-floating = [ "<Super>g" ];
      toggle-stacking-global = [ "<Super>s" ];
      toggle-tiling = [ "<Super>y" ];
    };
    "org/gnome/shell/keybindings" = {
      open-application-menu = [ ];
      toggle-message-tray = [ "<Super>v" ];
      toggle-overview = [ ];
    };
  };
  # Enable Pop Shell extension
  programs.gnome-shell = {
    enable = true;
    extensions = [
      { package = pkgs.gnomeExtensions.pop-shell; }
    ];
  };
}
