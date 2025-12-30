{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  # Helper function for DMS IPC commands
  dmsIPC =
    cmd:
    [
      "dms"
      "ipc"
      "call"
    ]
    ++ (pkgs.lib.splitString " " cmd);

  # Keybinding definitions for different compositors
  keybinds = {
    spotlight = {
      hyprland = "$mainMod, SPACE, exec, ${pkgs.lib.concatStringsSep " " (dmsIPC "spotlight toggle")}";
      niri = {
        key = "Mod+Space";
        action = dmsIPC "spotlight toggle";
      };
    };

    dashboard = {
      hyprland = "$mainMod, D, exec, ${pkgs.lib.concatStringsSep " " (dmsIPC "dashboard toggle")}";
      niri = {
        key = "Mod+D";
        action = dmsIPC "dashboard toggle";
      };
    };

    controlCenter = {
      hyprland = "$mainMod, C, exec, ${pkgs.lib.concatStringsSep " " (dmsIPC "controlCenter toggle")}";
      niri = {
        key = "Mod+C";
        action = dmsIPC "controlCenter toggle";
      };
    };

    clipboard = {
      hyprland = "$mainMod, V, exec, ${pkgs.lib.concatStringsSep " " (dmsIPC "clipboard toggle")}";
      niri = {
        key = "Mod+V";
        action = dmsIPC "clipboard toggle";
      };
    };

    lockScreen = {
      hyprland = "$mainMod, L, exec, ${pkgs.lib.concatStringsSep " " (dmsIPC "lockScreen lock")}";
      niri = {
        key = "Mod+L";
        action = dmsIPC "lockScreen lock";
      };
    };

    lockKey = {
      hyprland = ",XF86Lock, exec, ${pkgs.lib.concatStringsSep " " (dmsIPC "lockScreen lock")}";
      # XF86Lock is not a valid key in niri
    };

    brightnessUp = {
      hyprland = ",XF86MonBrightnessUp, exec, ${pkgs.lib.concatStringsSep " " (dmsIPC "brightness increase")}";
      niri = {
        key = "XF86MonBrightnessUp";
        action = dmsIPC "brightness increase";
      };
    };

    brightnessDown = {
      hyprland = ",XF86MonBrightnessDown, exec, ${pkgs.lib.concatStringsSep " " (dmsIPC "brightness decrease")}";
      niri = {
        key = "XF86MonBrightnessDown";
        action = dmsIPC "brightness decrease";
      };
    };

    volumeUp = {
      hyprland = ",XF86AudioRaiseVolume, exec, ${pkgs.lib.concatStringsSep " " (dmsIPC "audio setvolume +5")}";
      niri = {
        key = "XF86AudioRaiseVolume";
        action = dmsIPC "audio setvolume +5";
      };
    };

    volumeDown = {
      hyprland = ",XF86AudioLowerVolume, exec, ${pkgs.lib.concatStringsSep " " (dmsIPC "audio setvolume -5")}";
      niri = {
        key = "XF86AudioLowerVolume";
        action = dmsIPC "audio setvolume -5";
      };
    };

    volumeMute = {
      hyprland = ",XF86AudioMute, exec, ${pkgs.lib.concatStringsSep " " (dmsIPC "audio togglemute")}";
      niri = {
        key = "XF86AudioMute";
        action = dmsIPC "audio togglemute";
      };
    };

    micMute = {
      hyprland = ",XF86AudioMicMute, exec, ${pkgs.lib.concatStringsSep " " (dmsIPC "audio togglemicmute")}";
      niri = {
        key = "XF86AudioMicMute";
        action = dmsIPC "audio togglemicmute";
      };
    };

    mediaPlay = {
      hyprland = ",XF86AudioPlay, exec, ${pkgs.lib.concatStringsSep " " (dmsIPC "media playpause")}";
      niri = {
        key = "XF86AudioPlay";
        action = dmsIPC "media playpause";
      };
    };

    mediaNext = {
      hyprland = ",XF86AudioNext, exec, ${pkgs.lib.concatStringsSep " " (dmsIPC "media next")}";
      niri = {
        key = "XF86AudioNext";
        action = dmsIPC "media next";
      };
    };

    mediaPrev = {
      hyprland = ",XF86AudioPrev, exec, ${pkgs.lib.concatStringsSep " " (dmsIPC "media previous")}";
      niri = {
        key = "XF86AudioPrev";
        action = dmsIPC "media previous";
      };
    };
  };
in

{
  imports = [ inputs.dms.homeModules.default ];

  options.myConfig.programs.dms.keybindings = lib.mkOption {
    type = lib.types.attrs;
    default = { };
    description = "Keybinding definitions for DMS IPC commands";
  };

  config = {
    programs.dank-material-shell.enable = true;
    myConfig.programs.dms.keybindings = keybinds;
  };
}
