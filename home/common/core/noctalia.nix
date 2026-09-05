{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:

let
  # IPC command as a single shell string (e.g. "noctalia msg panel-toggle launcher")
  ipcCmd = cmd: lib.concatStringsSep " " (noctaliaIPC cmd);
  # Keybinding definitions for different compositors.
  # The hyprland consumer expects a set { key; cmd; } (see hyprland/default.nix mkShellBind).
  keybinds = {
    # Control Center tabs. Audio, Bluetooth and network have no standalone
    # panels; they are contexts of the control-center panel.
    audioPanel = {
      hyprland = {
        cmd = ipcCmd "panel-toggle control-center audio";
        key = "SUPER + CTRL + A";
      };

      niri = {
        action = noctaliaIPC "panel-toggle control-center audio";
        key = "Mod+Ctrl+A";
      };
    };

    bluetoothPanel = {
      hyprland = {
        cmd = ipcCmd "panel-toggle control-center bluetooth";
        key = "SUPER + CTRL + B";
      };

      niri = {
        action = noctaliaIPC "panel-toggle control-center bluetooth";
        key = "Mod+Ctrl+B";
      };
    };

    brightnessDown = {
      hyprland = {
        cmd = ipcCmd "brightness-down";
        key = "XF86MonBrightnessDown";
      };

      niri = {
        action = noctaliaIPC "brightness-down";
        key = "XF86MonBrightnessDown";
      };
    };

    brightnessUp = {
      hyprland = {
        cmd = ipcCmd "brightness-up";
        key = "XF86MonBrightnessUp";
      };

      niri = {
        action = noctaliaIPC "brightness-up";
        key = "XF86MonBrightnessUp";
      };
    };

    clipboard = {
      hyprland = {
        cmd = ipcCmd "panel-toggle clipboard";
        key = "SUPER + SHIFT + V";
      };

      niri = {
        action = noctaliaIPC "panel-toggle clipboard";
        key = "Mod+Shift+V";
      };
    };

    # Emoji picker: the launcher's built-in emoji provider replaces emote.
    emoji = {
      hyprland = {
        cmd = ipcCmd "panel-toggle launcher /emo";
        key = "SUPER + CTRL + E";
      };

      niri = {
        action = noctaliaIPC "panel-toggle launcher /emo";
        key = "Mod+Ctrl+E";
      };
    };

    launcher = {
      hyprland = {
        cmd = ipcCmd "panel-toggle launcher";
        key = "SUPER + SPACE";
      };

      niri = {
        action = noctaliaIPC "panel-toggle launcher";
        key = "Mod+Space";
      };
    };

    lockKey = {
      hyprland = {
        cmd = ipcCmd "session lock";
        key = "XF86Lock";
      };
      # XF86Lock is not a valid key in niri
    };

    lockScreen = {
      hyprland = {
        cmd = ipcCmd "session lock";
        key = "SUPER + CTRL + Escape";
      };

      niri = {
        action = noctaliaIPC "session lock";
        key = "Mod+Ctrl+Escape";
      };
    };

    micMute = {
      hyprland = {
        cmd = ipcCmd "mic-mute";
        key = "XF86AudioMicMute";
      };

      niri = {
        action = noctaliaIPC "mic-mute";
        key = "XF86AudioMicMute";
      };
    };

    networkPanel = {
      hyprland = {
        cmd = ipcCmd "panel-toggle control-center network";
        key = "SUPER + CTRL + W";
      };

      niri = {
        action = noctaliaIPC "panel-toggle control-center network";
        key = "Mod+Ctrl+W";
      };
    };

    nightlight = {
      hyprland = {
        cmd = ipcCmd "nightlight-toggle";
        key = "SUPER + CTRL + N";
      };

      niri = {
        action = noctaliaIPC "nightlight-toggle";
        key = "Mod+Ctrl+N";
      };
    };

    # System action menu (the overflow valve for infrequent actions)
    omniMenu = {
      hyprland = {
        cmd = "omni-menu";
        key = "SUPER + ALT + SPACE";
      };

      niri = {
        action = [ "omni-menu" ];
        key = "Mod+Alt+Space";
      };
    };

    volumeDown = {
      hyprland = {
        cmd = ipcCmd "volume-down";
        key = "XF86AudioLowerVolume";
      };

      niri = {
        action = noctaliaIPC "volume-down";
        key = "XF86AudioLowerVolume";
      };
    };

    volumeMute = {
      hyprland = {
        cmd = ipcCmd "volume-mute";
        key = "XF86AudioMute";
      };

      niri = {
        action = noctaliaIPC "volume-mute";
        key = "XF86AudioMute";
      };
    };

    volumeUp = {
      hyprland = {
        cmd = ipcCmd "volume-up";
        key = "XF86AudioRaiseVolume";
      };

      niri = {
        action = noctaliaIPC "volume-up";
        key = "XF86AudioRaiseVolume";
      };
    };
  };
  # Helper function for Noctalia IPC commands (v5+ uses `noctalia msg <command>`)
  noctaliaIPC =
    cmd:
    [
      "noctalia"
      "msg"
    ]
    ++ (lib.splitString " " cmd);
  # System action menu, rendered by noctalia's own launcher via `noctalia
  # dmenu` (reads items on stdin, prints the selection on stdout). This is the
  # overflow valve for actions that do not deserve a dedicated chord.
  #
  # The script itself lives in dotfiles/noctalia/omni-menu.sh so it can be
  # edited live without a rebuild; this only pins its runtime dependencies.
  omniMenu = pkgs.writeShellApplication {
    name = "omni-menu";
    runtimeInputs = with pkgs; [ jq ];

    text = ''
      exec bash ${lib.custom.symlink.path config "noctalia/omni-menu.sh"} "$@"
    '';
  };
in

{
  config = {
    home = {
      # Noctalia v13+ stores all transferable config (bar layout, enabled
      # plugins, theme/colors, and every GUI setting) in a single TOML file at
      # $XDG_STATE_HOME/noctalia/settings.toml. Out-of-store symlink it to the
      # live repo so GUI edits persist there and rebuilds aren't needed.
      file.".local/state/noctalia/settings.toml".source =
        lib.custom.symlink.link config "noctalia/settings.toml";

      packages = [ omniMenu ];
    };

    myConfig.programs.noctalia.keybindings = keybinds;
    programs.noctalia.enable = true;
  };

  imports = [ inputs.noctalia.homeModules.default ];

  options.myConfig.programs.noctalia.keybindings = lib.mkOption {
    default = { };
    description = "Keybinding definitions for Noctalia IPC commands";
    type = lib.types.attrs;
  };
}
