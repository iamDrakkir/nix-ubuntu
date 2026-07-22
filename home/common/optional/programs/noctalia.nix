{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  # Helper for Noctalia v5 IPC commands: `noctalia msg <command> [args...]`.
  # (Replaces the old quickshell `noctalia-shell ipc call <target> <method>`.)
  noctaliaIPC =
    cmd:
    [
      "noctalia"
      "msg"
    ]
    ++ (pkgs.lib.splitString " " cmd);

  # Keybinding definitions for different compositors
  keybinds = {
    brightnessDown = {
      hyprland = {
        cmd = pkgs.lib.concatStringsSep " " (noctaliaIPC "brightness-down");
        key = "XF86MonBrightnessDown";
      };
      niri = {
        action = noctaliaIPC "brightness-down";
        key = "XF86MonBrightnessDown";
      };
    };
    brightnessUp = {
      hyprland = {
        cmd = pkgs.lib.concatStringsSep " " (noctaliaIPC "brightness-up");
        key = "XF86MonBrightnessUp";
      };
      niri = {
        action = noctaliaIPC "brightness-up";
        key = "XF86MonBrightnessUp";
      };
    };
    clipboard = {
      hyprland = {
        cmd = pkgs.lib.concatStringsSep " " (noctaliaIPC "panel-toggle clipboard");
        key = "SUPER + V";
      };
      niri = {
        action = noctaliaIPC "panel-toggle clipboard";
        key = "Mod+V";
      };
    };
    launcher = {
      hyprland = {
        cmd = pkgs.lib.concatStringsSep " " (noctaliaIPC "panel-toggle launcher");
        key = "SUPER + SPACE";
      };
      niri = {
        action = noctaliaIPC "panel-toggle launcher";
        key = "Mod+Space";
      };
    };
    lockKey = {
      hyprland = {
        cmd = pkgs.lib.concatStringsSep " " (noctaliaIPC "session lock");
        key = "XF86Lock";
      };
      # XF86Lock is not a valid key in niri
    };
    # Noctalia v5 ignores the logind "lock-session" signal (loginctl lock-session
    # returns 0 but does not engage the lockscreen). v5.0.0 exposes a direct IPC
    # session action instead: `noctalia msg session lock`.
    lockScreen = {
      hyprland = {
        cmd = pkgs.lib.concatStringsSep " " (noctaliaIPC "session lock");
        key = "SUPER + X";
      };
      niri = {
        action = noctaliaIPC "session lock";
        key = "Mod+X";
      };
    };
    micMute = {
      hyprland = {
        cmd = pkgs.lib.concatStringsSep " " (noctaliaIPC "mic-mute");
        key = "XF86AudioMicMute";
      };
      niri = {
        action = noctaliaIPC "mic-mute";
        key = "XF86AudioMicMute";
      };
    };
    volumeDown = {
      hyprland = {
        cmd = pkgs.lib.concatStringsSep " " (noctaliaIPC "volume-down");
        key = "XF86AudioLowerVolume";
      };
      niri = {
        action = noctaliaIPC "volume-down";
        key = "XF86AudioLowerVolume";
      };
    };
    volumeMute = {
      hyprland = {
        cmd = pkgs.lib.concatStringsSep " " (noctaliaIPC "volume-mute");
        key = "XF86AudioMute";
      };
      niri = {
        action = noctaliaIPC "volume-mute";
        key = "XF86AudioMute";
      };
    };
    volumeUp = {
      hyprland = {
        cmd = pkgs.lib.concatStringsSep " " (noctaliaIPC "volume-up");
        key = "XF86AudioRaiseVolume";
      };
      niri = {
        action = noctaliaIPC "volume-up";
        key = "XF86AudioRaiseVolume";
      };
    };
  };
in

{
  config = {
    myConfig.programs.noctalia.keybindings = keybinds;
    programs.noctalia.enable = true;
    xdg.configFile = lib.custom.symlink.mkXdgConfigLinks config [
      "noctalia/colors.json"
      "noctalia/settings.json"
      "noctalia/plugins.json"
    ];
  };
  imports = [ inputs.noctalia.homeModules.default ];
  options.myConfig.programs.noctalia.keybindings = lib.mkOption {
    default = { };
    description = "Keybinding definitions for Noctalia IPC commands";
    type = lib.types.attrs;
  };
}
