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

  # IPC command as a single shell string (e.g. "noctalia msg panel-toggle launcher")
  ipcCmd = cmd: pkgs.lib.concatStringsSep " " (noctaliaIPC cmd);

  # Keybinding definitions for different compositors.
  # The hyprland consumer expects a set { key; cmd; } (see hyprland/default.nix mkShellBind).
  keybinds = {
    launcher = {
      hyprland = {
        key = "SUPER + SPACE";
        cmd = ipcCmd "panel-toggle launcher";
      };
      niri = {
        key = "Mod+Space";
        action = noctaliaIPC "panel-toggle launcher";
      };
    };
    clipboard = {
      hyprland = {
        key = "SUPER + V";
        cmd = ipcCmd "panel-toggle clipboard";
      };
      niri = {
        action = noctaliaIPC "panel-toggle clipboard";
        key = "Mod+V";
      };
    };

    lockScreen = {
      hyprland = {
        key = "SUPER + X";
        cmd = ipcCmd "session lock";
      };
      niri = {
        key = "Mod+X";
        action = noctaliaIPC "session lock";
      };
    };
    lockKey = {
      hyprland = {
        key = "XF86Lock";
        cmd = ipcCmd "session lock";
      };
      # XF86Lock is not a valid key in niri
    };

    brightnessUp = {
      hyprland = {
        key = "XF86MonBrightnessUp";
        cmd = ipcCmd "brightness-up";
      };
      niri = {
        key = "XF86MonBrightnessUp";
        action = noctaliaIPC "brightness-up";
      };
    };

    brightnessDown = {
      hyprland = {
        key = "XF86MonBrightnessDown";
        cmd = ipcCmd "brightness-down";
      };
      niri = {
        key = "XF86MonBrightnessDown";
        action = noctaliaIPC "brightness-down";
      };
    };

    volumeUp = {
      hyprland = {
        key = "XF86AudioRaiseVolume";
        cmd = ipcCmd "volume-up";
      };
      niri = {
        key = "XF86AudioRaiseVolume";
        action = noctaliaIPC "volume-up";
      };
    };

    volumeDown = {
      hyprland = {
        key = "XF86AudioLowerVolume";
        cmd = ipcCmd "volume-down";
      };
      niri = {
        key = "XF86AudioLowerVolume";
        action = noctaliaIPC "volume-down";
      };
    };

    volumeMute = {
      hyprland = {
        key = "XF86AudioMute";
        cmd = ipcCmd "volume-mute";
      };
      niri = {
        key = "XF86AudioMute";
        action = noctaliaIPC "volume-mute";
      };
    };

    micMute = {
      hyprland = {
        key = "XF86AudioMicMute";
        cmd = ipcCmd "mic-mute";
      };
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
