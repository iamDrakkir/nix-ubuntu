{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  # Helper function for Noctalia IPC commands (v5+ uses `noctalia msg <command>`)
  noctaliaIPC =
    cmd:
    [
      "noctalia"
      "msg"
    ]
    ++ (pkgs.lib.splitString " " cmd);

  # Keybinding definitions for different compositors
  keybinds = {
    launcher = {
      hyprland = "$mainMod, SPACE, exec, ${pkgs.lib.concatStringsSep " " (noctaliaIPC "panel-toggle launcher")}";
      niri = {
        key = "Mod+Space";
        action = noctaliaIPC "panel-toggle launcher";
      };
    };
    clipboard = {
      hyprland = "$mainMod, V, exec, ${pkgs.lib.concatStringsSep " " (noctaliaIPC "panel-toggle clipboard")}";
      niri = {
        action = noctaliaIPC "panel-toggle clipboard";
        key = "Mod+V";
      };
    };

    lockScreen = {
      hyprland = "$mainMod, X, exec, ${pkgs.lib.concatStringsSep " " (noctaliaIPC "session lock")}";
      niri = {
        key = "Mod+X";
        action = noctaliaIPC "session lock";
      };
    };
    lockKey = {
      hyprland = ",XF86Lock, exec, ${pkgs.lib.concatStringsSep " " (noctaliaIPC "session lock")}";
      # XF86Lock is not a valid key in niri
    };

    brightnessUp = {
      hyprland = ",XF86MonBrightnessUp, exec, ${pkgs.lib.concatStringsSep " " (noctaliaIPC "brightness-up")}";
      niri = {
        key = "XF86MonBrightnessUp";
        action = noctaliaIPC "brightness-up";
      };
    };

    brightnessDown = {
      hyprland = ",XF86MonBrightnessDown, exec, ${pkgs.lib.concatStringsSep " " (noctaliaIPC "brightness-down")}";
      niri = {
        key = "XF86MonBrightnessDown";
        action = noctaliaIPC "brightness-down";
      };
    };

    volumeUp = {
      hyprland = ",XF86AudioRaiseVolume, exec, ${pkgs.lib.concatStringsSep " " (noctaliaIPC "volume-up")}";
      niri = {
        key = "XF86AudioRaiseVolume";
        action = noctaliaIPC "volume-up";
      };
    };

    volumeDown = {
      hyprland = ",XF86AudioLowerVolume, exec, ${pkgs.lib.concatStringsSep " " (noctaliaIPC "volume-down")}";
      niri = {
        key = "XF86AudioLowerVolume";
        action = noctaliaIPC "volume-down";
      };
    };

    volumeMute = {
      hyprland = ",XF86AudioMute, exec, ${pkgs.lib.concatStringsSep " " (noctaliaIPC "volume-mute")}";
      niri = {
        key = "XF86AudioMute";
        action = noctaliaIPC "volume-mute";
      };
    };

    micMute = {
      hyprland = ",XF86AudioMicMute, exec, ${pkgs.lib.concatStringsSep " " (noctaliaIPC "mic-mute")}";
      niri = {
        key = "XF86AudioMicMute";
        action = noctaliaIPC "mic-mute";
      };
    };
  };
in

{
  config = {
    myConfig.programs.noctalia.keybindings = keybinds;
    programs.noctalia.enable = true;
    # Noctalia v13+ stores all transferable config (bar layout, enabled
    # plugins, theme/colors, and every GUI setting) in a single TOML file at
    # $XDG_STATE_HOME/noctalia/settings.toml. Out-of-store symlink it to the
    # live repo so GUI edits persist there and rebuilds aren't needed.
    home.file.".local/state/noctalia/settings.toml".source =
      lib.custom.symlink.link config "noctalia/settings.toml";
  };
  imports = [ inputs.noctalia.homeModules.default ];
  options.myConfig.programs.noctalia.keybindings = lib.mkOption {
    default = { };
    description = "Keybinding definitions for Noctalia IPC commands";
    type = lib.types.attrs;
  };
}
