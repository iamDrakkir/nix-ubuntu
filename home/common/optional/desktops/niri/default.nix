{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  # Conditionally use Noctalia keybindings
  kb = config.myConfig.programs.noctalia.keybindings or { };
  noctaliaEnabled = kb != { };
in

{
  imports = [ inputs.niri.homeModules.niri ];

  home.packages = with pkgs; [
    niri
    # Wayland utilities for Niri
    grim # Screenshot tool
    slurp # Screen area selector
    wl-clipboard # Clipboard utilities
    wl-clipboard-x11 # X11 compatibility
  ];

  # Configure Niri window manager
  programs.niri = {
    settings = {
      # Conditionally spawn Noctalia on startup
      spawn-at-startup = lib.optionals noctaliaEnabled [ { command = [ "noctalia-shell" ]; } ];

      # Input configuration
      input = {
        keyboard = {
          xkb = {
            layout = "se";
          };
        };
        touchpad = {
          tap = true;
          natural-scroll = true;
        };
      };

      # Layout configuration
      layout = {
        gaps = 8;
        center-focused-column = "never";
        default-column-width = { };
        preset-column-widths = [
          { proportion = 0.33333; }
          { proportion = 0.5; }
          { proportion = 0.66667; }
        ];
      };

      # Window rules
      window-rules = [ ];

      # Keybindings
      binds =
        with config.lib.niri.actions;
        lib.optionalAttrs noctaliaEnabled {
          # Noctalia keybindings (only if enabled)
          "${kb.launcher.niri.key}".action.spawn = kb.launcher.niri.action;
          "${kb.calendar.niri.key}".action.spawn = kb.calendar.niri.action;
          "${kb.clipboard.niri.key}".action.spawn = kb.clipboard.niri.action;
          "${kb.lockScreen.niri.key}".action.spawn = kb.lockScreen.niri.action;

          # Brightness controls
          "${kb.brightnessUp.niri.key}".action.spawn = kb.brightnessUp.niri.action;
          "${kb.brightnessDown.niri.key}".action.spawn = kb.brightnessDown.niri.action;

          # Volume controls
          "${kb.volumeUp.niri.key}".action.spawn = kb.volumeUp.niri.action;
          "${kb.volumeDown.niri.key}".action.spawn = kb.volumeDown.niri.action;
          "${kb.volumeMute.niri.key}".action.spawn = kb.volumeMute.niri.action;
          "${kb.micMute.niri.key}".action.spawn = kb.micMute.niri.action;
        }
        // {
          # Terminal
          "Mod+Return".action.spawn = [ "ghostty" ];
          "Mod+Shift+Return".action.spawn = [ "kitty" ];

          # Applications
          "Mod+E".action.spawn = [ "nautilus" ];
          "Mod+B".action.spawn = [
            "zen"
            "-p"
            "Personal"
          ];
          "Mod+Shift+B".action.spawn = [
            "zen"
            "-p"
            "Work"
          ];
          "Mod+P".action.spawn = [ "1password" ];
          "Mod+Shift+P".action.spawn = [
            "1password"
            "--quick-access"
          ];
          "Mod+D".action.spawn = [ "discord" ];

          # Window management
          "Mod+Q".action.close-window = [ ];
          "Mod+F".action.fullscreen-window = [ ];
          "Mod+T".action.set-window-height = [
            "+10%"
          ];
          "Mod+Shift+T".action.set-window-height = [
            "-10%"
          ];

          # Focus movement
          "Mod+Left".action.focus-column-left = [ ];
          "Mod+Right".action.focus-column-right = [ ];
          "Mod+Up".action.focus-window-up = [ ];
          "Mod+Down".action.focus-window-down = [ ];
          "Mod+H".action.focus-column-left = [ ];
          "Mod+L".action.focus-column-right = [ ];
          "Mod+K".action.focus-window-up = [ ];
          "Mod+J".action.focus-window-down = [ ];

          # Window movement
          "Mod+Ctrl+Left".action.move-column-left = [ ];
          "Mod+Ctrl+Right".action.move-column-right = [ ];
          "Mod+Ctrl+Up".action.move-window-up = [ ];
          "Mod+Ctrl+Down".action.move-window-down = [ ];
          "Mod+Ctrl+H".action.move-column-left = [ ];
          "Mod+Ctrl+L".action.move-column-right = [ ];
          "Mod+Ctrl+K".action.move-window-up = [ ];
          "Mod+Ctrl+J".action.move-window-down = [ ];

          # Window sizing
          "Mod+Shift+Left".action.set-column-width = [
            "-10%"
          ];
          "Mod+Shift+Right".action.set-column-width = [
            "+10%"
          ];
          "Mod+Shift+H".action.set-column-width = [
            "-10%"
          ];
          "Mod+Shift+R".action.set-column-width = [
            "+10%"
          ];

          # Workspace switching
          "Mod+1".action.focus-workspace = [ 1 ];
          "Mod+2".action.focus-workspace = [ 2 ];
          "Mod+3".action.focus-workspace = [ 3 ];
          "Mod+4".action.focus-workspace = [ 4 ];
          "Mod+5".action.focus-workspace = [ 5 ];
          "Mod+6".action.focus-workspace = [ 6 ];
          "Mod+7".action.focus-workspace = [ 7 ];
          "Mod+8".action.focus-workspace = [ 8 ];
          "Mod+9".action.focus-workspace = [ 9 ];
          "Mod+0".action.focus-workspace = [ 10 ];

          # Move window to workspace
          "Mod+Shift+1".action.move-window-to-workspace = [ 1 ];
          "Mod+Shift+2".action.move-window-to-workspace = [ 2 ];
          "Mod+Shift+3".action.move-window-to-workspace = [ 3 ];
          "Mod+Shift+4".action.move-window-to-workspace = [ 4 ];
          "Mod+Shift+5".action.move-window-to-workspace = [ 5 ];
          "Mod+Shift+6".action.move-window-to-workspace = [ 6 ];
          "Mod+Shift+7".action.move-window-to-workspace = [ 7 ];
          "Mod+Shift+8".action.move-window-to-workspace = [ 8 ];
          "Mod+Shift+9".action.move-window-to-workspace = [ 9 ];
          "Mod+Shift+0".action.move-window-to-workspace = [ 10 ];

          # Screenshots
          "Print".action.screenshot = [ ];
          "Shift+Print".action.screenshot-screen = [ ];
          "Mod+Print".action.screenshot-window = [ ];
        };
    };
  };
}
