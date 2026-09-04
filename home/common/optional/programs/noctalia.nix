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

  # System action menu, rendered by noctalia's own launcher via `noctalia
  # dmenu` (reads items on stdin, prints the selection on stdout). This is the
  # overflow valve for actions that do not deserve a dedicated chord.
  omniMenu = pkgs.writeShellApplication {
    name = "omni-menu";
    runtimeInputs = with pkgs; [ jq ];
    text = ''
      # Present "key<TAB>description" pairs and echo back only the key.
      # noctalia dmenu exits non-zero when dismissed, so callers exit quietly.
      pick() {
        local prompt="$1"
        shift
        local sel
        sel=$(printf '%s\t%s\n' "$@" | noctalia dmenu -p "$prompt") || return 1
        printf '%s' "''${sel%%$'\t'*}"
      }

      # Run a command in a terminal and hold the window open so output is
      # readable; `noctalia dmenu` actions are otherwise detached.
      in_term() {
        ghostty -e bash -lc "$1; printf '\n[done] press enter to close'; read -r" &
      }

      menu_nix() {
        local dir="$HOME/.config/nix"
        case "$(pick 'Nix' \
          'Home'     'Rebuild home-manager' \
          'System'   'Rebuild system-manager / NixOS' \
          'Rebuild'  'Rebuild home and system' \
          'Update'   'Update flake inputs' \
          'Check'    'Evaluate all configurations' \
          'Edit'     'Open the config in an editor')" in
          'Home')    in_term "cd '$dir' && just home" ;;
          'System')  in_term "cd '$dir' && just system" ;;
          'Rebuild') in_term "cd '$dir' && just rebuild" ;;
          'Update')  in_term "cd '$dir' && just update" ;;
          'Check')   in_term "cd '$dir' && just check" ;;
          'Edit')    in_term "cd '$dir' && \''${EDITOR:-nvim} ." ;;
        esac
      }

      menu_toggles() {
        case "$(pick 'Toggles' \
          'Dark mode'  'Switch light/dark theme' \
          'Nightlight' 'Warm the display colours' \
          'Caffeine'   'Keep the screen awake' \
          'Do not disturb' 'Silence notifications' \
          'OSD'        'On-screen volume/brightness popups' \
          'Bar'        'Show or hide the bar' \
          'WiFi'       'Enable or disable WiFi' \
          'Bluetooth'  'Enable or disable Bluetooth')" in
          'Dark mode')      noctalia msg theme-mode-toggle ;;
          'Nightlight')     noctalia msg nightlight-toggle ;;
          'Caffeine')       noctalia msg caffeine-toggle ;;
          'Do not disturb') noctalia msg notification-dnd-toggle ;;
          'OSD')            noctalia msg osd-toggle ;;
          'Bar')            noctalia msg bar-toggle ;;
          'WiFi')           noctalia msg wifi-toggle ;;
          'Bluetooth')      noctalia msg bluetooth-toggle ;;
        esac
      }

      # Enumerate outputs from whichever compositor is running.
      outputs_list() {
        if [ -n "''${NIRI_SOCKET:-}" ]; then
          niri msg --json outputs \
            | jq -r 'if type == "object" then keys[] else .[].name end'
        elif [ -n "''${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then
          hyprctl monitors -j | jq -r '.[].name'
        fi
      }

      output_set() {
        local name="$1" state="$2"
        if [ -n "''${NIRI_SOCKET:-}" ]; then
          niri msg output "$name" "$state"
        elif [ -n "''${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then
          case "$state" in
            off) hyprctl keyword monitor "$name,disable" ;;
            on)  hyprctl keyword monitor "$name,preferred,auto,1" ;;
          esac
        fi
      }

      menu_output() {
        local name="$1"
        case "$(pick "$name" \
          'Enable'  'Turn this output on' \
          'Disable' 'Turn this output off')" in
          'Enable')  output_set "$name" on ;;
          'Disable') output_set "$name" off ;;
        esac
      }

      menu_display() {
        local args=(
          'Settings'  'Open the monitor control centre'
          'Wallpaper' 'Next wallpaper'
          'Random'    'Random wallpaper'
        )
        local name
        while read -r name; do
          [ -n "$name" ] && args+=("$name" 'Enable or disable this output')
        done < <(outputs_list)

        local choice
        choice=$(pick 'Display' "''${args[@]}") || return 0
        case "$choice" in
          'Settings')  noctalia msg panel-toggle control-center monitor ;;
          'Wallpaper') noctalia msg wallpaper-next ;;
          'Random')    noctalia msg wallpaper-random ;;
          "")          ;;
          *)           menu_output "$choice" ;;
        esac
      }

      case "$(pick 'System' \
        'Session'  'Lock, suspend, reboot, shut down' \
        'Nix'      'Rebuild, update, edit the config' \
        'Toggles'  'Theme, nightlight, caffeine, DND' \
        'Display'  'Outputs and wallpaper')" in
        # Noctalia already has a session panel; hand off rather than
        # reimplementing the same list in the menu.
        'Session') noctalia msg panel-open session ;;
        'Nix')     menu_nix ;;
        'Toggles') menu_toggles ;;
        'Display') menu_display ;;
      esac
    '';
  };

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
        key = "SUPER + SHIFT + V";
        cmd = ipcCmd "panel-toggle clipboard";
      };
      niri = {
        action = noctaliaIPC "panel-toggle clipboard";
        key = "Mod+Shift+V";
      };
    };

    # System action menu (the overflow valve for infrequent actions)
    omniMenu = {
      hyprland = {
        key = "SUPER + ALT + SPACE";
        cmd = "omni-menu";
      };
      niri = {
        key = "Mod+Alt+Space";
        action = [ "omni-menu" ];
      };
    };

    # Emoji picker: the launcher's built-in emoji provider replaces emote.
    emoji = {
      hyprland = {
        key = "SUPER + CTRL + E";
        cmd = ipcCmd "panel-toggle launcher /emo";
      };
      niri = {
        key = "Mod+Ctrl+E";
        action = noctaliaIPC "panel-toggle launcher /emo";
      };
    };

    # Control Center tabs. Audio, Bluetooth and network have no standalone
    # panels; they are contexts of the control-center panel.
    audioPanel = {
      hyprland = {
        key = "SUPER + CTRL + A";
        cmd = ipcCmd "panel-toggle control-center audio";
      };
      niri = {
        key = "Mod+Ctrl+A";
        action = noctaliaIPC "panel-toggle control-center audio";
      };
    };

    bluetoothPanel = {
      hyprland = {
        key = "SUPER + CTRL + B";
        cmd = ipcCmd "panel-toggle control-center bluetooth";
      };
      niri = {
        key = "Mod+Ctrl+B";
        action = noctaliaIPC "panel-toggle control-center bluetooth";
      };
    };

    networkPanel = {
      hyprland = {
        key = "SUPER + CTRL + W";
        cmd = ipcCmd "panel-toggle control-center network";
      };
      niri = {
        key = "Mod+Ctrl+W";
        action = noctaliaIPC "panel-toggle control-center network";
      };
    };

    nightlight = {
      hyprland = {
        key = "SUPER + CTRL + N";
        cmd = ipcCmd "nightlight-toggle";
      };
      niri = {
        key = "Mod+Ctrl+N";
        action = noctaliaIPC "nightlight-toggle";
      };
    };

    lockScreen = {
      hyprland = {
        key = "SUPER + CTRL + Escape";
        cmd = ipcCmd "session lock";
      };
      niri = {
        key = "Mod+Ctrl+Escape";
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
    home.packages = [ omniMenu ];
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
