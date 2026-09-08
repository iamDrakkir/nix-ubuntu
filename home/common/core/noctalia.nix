{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:

let
  # Every Noctalia bind in neutral form; the per-compositor variants are
  # expanded from this below. `cmd` is the IPC command, `key` the chord in the
  # syntax niri and umbriel share, `hyprKey` hyprland's spelling of it.
  binds = {
    # Control Center tabs. Audio, Bluetooth and network have no standalone
    # panels; they are contexts of the control-center panel.
    audioPanel = {
      cmd = "panel-toggle control-center audio";
      hyprKey = "SUPER + CTRL + A";
      key = "Mod+Ctrl+A";
    };

    bluetoothPanel = {
      cmd = "panel-toggle control-center bluetooth";
      hyprKey = "SUPER + CTRL + B";
      key = "Mod+Ctrl+B";
    };

    brightnessDown = {
      cmd = "brightness-down";
      hyprKey = "XF86MonBrightnessDown";
      key = "XF86MonBrightnessDown";
    };

    brightnessUp = {
      cmd = "brightness-up";
      hyprKey = "XF86MonBrightnessUp";
      key = "XF86MonBrightnessUp";
    };

    clipboard = {
      cmd = "panel-toggle clipboard";
      hyprKey = "SUPER + SHIFT + V";
      key = "Mod+Shift+V";
    };

    # Emoji picker: the launcher's built-in emoji provider replaces emote.
    emoji = {
      cmd = "panel-toggle launcher /emo";
      hyprKey = "SUPER + CTRL + E";
      key = "Mod+Ctrl+E";
    };

    launcher = {
      cmd = "panel-toggle launcher";
      hyprKey = "SUPER + SPACE";
      key = "Mod+Space";
    };

    launcherProviders = {
      cmd = "panel-toggle launcher /";
      hyprKey = "SUPER + ALT + SPACE";
      key = "Mod+Alt+Space";
    };

    # No `key`: XF86Lock is not a valid key in niri or umbriel.
    lockKey = {
      cmd = "session lock";
      hyprKey = "XF86Lock";
    };

    lockScreen = {
      cmd = "session lock";
      hyprKey = "SUPER + CTRL + Escape";
      key = "Mod+Ctrl+Escape";
    };

    micMute = {
      cmd = "mic-mute";
      hyprKey = "XF86AudioMicMute";
      key = "XF86AudioMicMute";
    };

    networkPanel = {
      cmd = "panel-toggle control-center network";
      hyprKey = "SUPER + CTRL + W";
      key = "Mod+Ctrl+W";
    };

    nightlight = {
      cmd = "nightlight-toggle";
      hyprKey = "SUPER + CTRL + N";
      key = "Mod+Ctrl+N";
    };

    volumeDown = {
      cmd = "volume-down";
      hyprKey = "XF86AudioLowerVolume";
      key = "XF86AudioLowerVolume";
    };

    volumeMute = {
      cmd = "volume-mute";
      hyprKey = "XF86AudioMute";
      key = "XF86AudioMute";
    };

    volumeUp = {
      cmd = "volume-up";
      hyprKey = "XF86AudioRaiseVolume";
      key = "XF86AudioRaiseVolume";
    };
  };
  # IPC command as a single shell string (e.g. "noctalia msg panel-toggle launcher")
  ipcCmd = cmd: lib.concatStringsSep " " (noctaliaIPC cmd);
  # The same bind in each compositor's own shape: hyprland wants a { key; cmd; }
  # pair (see hyprland/default.nix mkShellBind), niri an argv list, umbriel a
  # "spawn:" action. Binds without a `key` are hyprland-only.
  keybinds = lib.mapAttrs (
    _: b:
    {
      hyprland = {
        cmd = ipcCmd b.cmd;
        key = b.hyprKey;
      };
    }
    // lib.optionalAttrs (b ? key) {
      niri = {
        action = noctaliaIPC b.cmd;
        inherit (b) key;
      };

      umbriel = {
        action = "spawn:${ipcCmd b.cmd}";
        inherit (b) key;
      };
    }
  ) binds;
  # Helper function for Noctalia IPC commands (v5+ uses `noctalia msg <command>`)
  noctaliaIPC =
    cmd:
    [
      "noctalia"
      "msg"
    ]
    ++ (lib.splitString " " cmd);
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
