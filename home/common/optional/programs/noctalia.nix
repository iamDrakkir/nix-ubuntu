{
  config,
  lib,
  pkgs,
  inputs,
  homeDirectory,
  ...
}:

let
  # Helper function for Noctalia IPC commands
  noctaliaIPC =
    cmd:
    [
      "noctalia-shell"
      "ipc"
      "call"
    ]
    ++ (pkgs.lib.splitString " " cmd);

  # Keybinding definitions for different compositors
  keybinds = {
    launcher = {
      hyprland = "$mainMod, SPACE, exec, ${pkgs.lib.concatStringsSep " " (noctaliaIPC "launcher toggle")}";
      niri = {
        key = "Mod+Space";
        action = noctaliaIPC "launcher toggle";
      };
    };

    calendar = {
      hyprland = "$mainMod, C, exec, ${pkgs.lib.concatStringsSep " " (noctaliaIPC "calendar toggle")}";
      niri = {
        key = "Mod+C";
        action = noctaliaIPC "calendar toggle";
      };
    };

    clipboard = {
      hyprland = "$mainMod, V, exec, ${pkgs.lib.concatStringsSep " " (noctaliaIPC "launcher clipboard")}";
      niri = {
        key = "Mod+V";
        action = noctaliaIPC "launcher clipboard";
      };
    };

    lockScreen = {
      hyprland = "$mainMod, L, exec, ${pkgs.lib.concatStringsSep " " (noctaliaIPC "lockScreen lock")}";
      niri = {
        key = "Mod+L";
        action = noctaliaIPC "lockScreen lock";
      };
    };

    lockKey = {
      hyprland = ",XF86Lock, exec, ${pkgs.lib.concatStringsSep " " (noctaliaIPC "lockScreen lock")}";
      # XF86Lock is not a valid key in niri
    };

    brightnessUp = {
      hyprland = ",XF86MonBrightnessUp, exec, ${pkgs.lib.concatStringsSep " " (noctaliaIPC "brightness increase")}";
      niri = {
        key = "XF86MonBrightnessUp";
        action = noctaliaIPC "brightness increase";
      };
    };

    brightnessDown = {
      hyprland = ",XF86MonBrightnessDown, exec, ${pkgs.lib.concatStringsSep " " (noctaliaIPC "brightness decrease")}";
      niri = {
        key = "XF86MonBrightnessDown";
        action = noctaliaIPC "brightness decrease";
      };
    };

    volumeUp = {
      hyprland = ",XF86AudioRaiseVolume, exec, ${pkgs.lib.concatStringsSep " " (noctaliaIPC "volume increase")}";
      niri = {
        key = "XF86AudioRaiseVolume";
        action = noctaliaIPC "volume increase";
      };
    };

    volumeDown = {
      hyprland = ",XF86AudioLowerVolume, exec, ${pkgs.lib.concatStringsSep " " (noctaliaIPC "volume decrease")}";
      niri = {
        key = "XF86AudioLowerVolume";
        action = noctaliaIPC "volume decrease";
      };
    };

    volumeMute = {
      hyprland = ",XF86AudioMute, exec, ${pkgs.lib.concatStringsSep " " (noctaliaIPC "volume muteOutput")}";
      niri = {
        key = "XF86AudioMute";
        action = noctaliaIPC "volume muteOutput";
      };
    };

    micMute = {
      hyprland = ",XF86AudioMicMute, exec, ${pkgs.lib.concatStringsSep " " (noctaliaIPC "volume muteInput")}";
      niri = {
        key = "XF86AudioMicMute";
        action = noctaliaIPC "volume muteInput";
      };
    };
  };

  dotfilesPath = "${homeDirectory}/.config/nix/dotfiles/noctalia";
in

{
  imports = [ inputs.noctalia.homeModules.default ];

  options.myConfig.programs.noctalia.keybindings = lib.mkOption {
    type = lib.types.attrs;
    default = { };
    description = "Keybinding definitions for Noctalia IPC commands";
  };

  config = {
    programs.noctalia-shell.enable = true;

    xdg.configFile = {
      "noctalia/colors.json".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/colors.json";
      "noctalia/settings.json".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/settings.json";
      "noctalia/plugins.json".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/plugins.json";
    };

    myConfig.programs.noctalia.keybindings = keybinds;
  };
}
