{
  config,
  hostname,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  # Conditionally use Noctalia keybindings
  kb = config.myConfig.programs.noctalia.keybindings or { };
  noctaliaEnabled = kb != { };

  # Swap browser profile shortcuts based on host
  isWorkHost = hostname == "work";
  browserPersonalProfile = "Personal";
  browserWorkProfile = "Work";
in

{
  imports = [ inputs.niri.homeModules.niri ];

  home.packages = with pkgs; [
    # niri
    # Wayland utilities for Niri
    grim # Screenshot tool
    slurp # Screen area selector
    wl-clipboard # Clipboard utilities
    wl-clipboard-x11 # X11 compatibility
    satty
    xwayland-satellite
    xtrayhide # X11 tray to SNI bridge (hides X11 tray windows)
  ];

  # Import niri systemd service from the package
  # The niri home module doesn't automatically set this up, so we do it manually
  # Note: This service is started by niri-session, not automatically
  systemd.user.services.niri = {
    Unit = {
      Description = "A scrollable-tiling Wayland compositor";
      BindsTo = "graphical-session.target";
      Before = "graphical-session.target";
      Wants = [ "graphical-session-pre.target" "xdg-desktop-autostart.target" ];
      After = "graphical-session-pre.target";
    };
    Service = {
      Slice = "session.slice";
      Type = "notify";
      ExecStart = "${config.programs.niri.package}/bin/niri --session";
    };
    Install = {
      # Don't auto-start - niri-session handles starting this service
      WantedBy = lib.mkForce [ ];
    };
  };

  systemd.user.targets.niri-shutdown = {
    Unit.Description = "niri shutdown target";
  };

  # X11 System Tray to StatusNotifierItem bridge
  # xtrayhide captures X11 tray icons, hides them, and exposes them as SNI
  # This prevents the black container window issue with Wine/Battle.net
  systemd.user.services.xtrayhide = {
    Unit = {
      Description = "X11 System Tray to StatusNotifierItem bridge (with hidden windows)";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
      ConditionEnvironment = "WAYLAND_DISPLAY";
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.xtrayhide}/bin/xtrayhide";
      Restart = "on-failure";
      RestartSec = 3;
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  # Configure Niri window manager
  programs.niri = {
    package = pkgs.niri;
    enable = true;
    settings = {
      # Spawn applications at startup
      spawn-at-startup =
        [
          { command = [ "corectrl" ]; }
          # { command = [ "proton-pass" ]; } # can not start minimized.
        ]
        ++ lib.optionals noctaliaEnabled [ { command = [ "noctalia-shell" ]; } ];

      # Output configuration
      outputs = {
        "eDP-1" = {
          mode = {
            width = 1920;
            height = 1080;
            refresh = 60.00;
          };
          scale = 1.0;
          position = {
            x = 0;
            y = 0;
          };
        };
        "DP-1" = {
          mode = {
            width = 1920;
            height = 1080;
            refresh = 119.982;
          };
          position = {
            x = 0;
            y = 0;
          };
        };
        "DP-2" = {
          mode = {
            width = 2560;
            height = 1440;
            refresh = 143.998;
          };
          position = {
            x = 1920;
            y = 0;
          };
        };
      };

      # Input configuration
      input = {
        keyboard = {
          xkb = {
            layout = "se";
          };
        };
        touchpad = {
          tap = true;
          natural-scroll = false;
        };
        focus-follows-mouse = {
          enable = true;
          max-scroll-amount = "90%";
        };
      };

      # Layout configuration
      layout = {
        gaps = 16;
        center-focused-column = "never";
        always-center-single-column = true;
        default-column-width = {
          proportion = 0.5;
        };
        preset-column-widths = [
          { proportion = 0.33333; }
          { proportion = 0.5; }
          { proportion = 0.66667; }
        ];

        # Focus ring configuration
        focus-ring = {
          width = 4.0;
          active.color = "#7fc8ff";
          inactive.color = "#505050";
        };

        # Border configuration (disabled by default)
        border = {
          enable = false;
        };
      };

      # Window rules
      window-rules = [
        # Enable rounded corners for all windows
        {
          geometry-corner-radius = {
            top-left = 12.0;
            top-right = 12.0;
            bottom-left = 12.0;
            bottom-right = 12.0;
          };
          clip-to-geometry = true;
        }
      ];

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
          # Overview and hotkeys
          "Mod+O" = {
            action.toggle-overview = [ ];
            repeat = false;
          };
          "Mod+Shift+Slash".action.show-hotkey-overlay = [ ];

          # Terminal
          "Mod+Return".action.spawn = [ "ghostty" ];
          "Mod+Shift+Return".action.spawn = [ "kitty" ];

          # Applications
          "Mod+E".action.spawn = [ "nautilus" ];
          "Mod+B".action.spawn = [
            "zen"
            "-p"
            (if isWorkHost then browserWorkProfile else browserPersonalProfile)
          ];
          "Mod+Shift+B".action.spawn = [
            "zen"
            "-p"
            (if isWorkHost then browserPersonalProfile else browserWorkProfile)
          ];
          "Mod+Ctrl+Shift+B".action.spawn = [
            "zen"
            "-p"
            "Work_Admin"
          ];
          "Mod+P".action.spawn = [ "proton-pass" ];
          "Mod+D".action.spawn = [ "discord" ];

          # Window management
          "Mod+Q" = {
            action.close-window = [ ];
            repeat = false;
          };
          "Mod+F".action.maximize-column = [ ];
          "Mod+Shift+F".action.fullscreen-window = [ ];
          "Mod+T".action.toggle-window-floating = [ ];
          "Mod+C".action.center-column = [ ];
          "Mod+Ctrl+C".action.center-visible-columns = [ ];
          "Mod+W".action.toggle-column-tabbed-display = [ ];

          # Column width presets
          "Mod+R".action.switch-preset-column-width = [ ];
          "Mod+Shift+R".action.switch-preset-window-height = [ ];
          "Mod+Ctrl+R".action.reset-window-height = [ ];
          "Mod+Ctrl+F".action.expand-column-to-available-width = [ ];

          # Finer adjustments
          "Mod+Minus".action.set-column-width = [ "-10%" ];
          "Mod+Equal".action.set-column-width = [ "+10%" ];
          "Mod+Shift+Minus".action.set-window-height = [ "-10%" ];
          "Mod+Shift+Equal".action.set-window-height = [ "+10%" ];

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

          # Monitor focus
          "Mod+Shift+Left".action.focus-monitor-left = [ ];
          "Mod+Shift+Right".action.focus-monitor-right = [ ];
          "Mod+Shift+Up".action.focus-monitor-up = [ ];
          "Mod+Shift+Down".action.focus-monitor-down = [ ];
          "Mod+Shift+H".action.focus-monitor-left = [ ];
          "Mod+Shift+L".action.focus-monitor-right = [ ];
          "Mod+Shift+K".action.focus-monitor-up = [ ];
          "Mod+Shift+J".action.focus-monitor-down = [ ];

          # Move to monitor
          "Mod+Shift+Ctrl+Left".action.move-column-to-monitor-left = [ ];
          "Mod+Shift+Ctrl+Right".action.move-column-to-monitor-right = [ ];
          "Mod+Shift+Ctrl+Up".action.move-column-to-monitor-up = [ ];
          "Mod+Shift+Ctrl+Down".action.move-column-to-monitor-down = [ ];
          "Mod+Shift+Ctrl+H".action.move-column-to-monitor-left = [ ];
          "Mod+Shift+Ctrl+L".action.move-column-to-monitor-right = [ ];
          "Mod+Shift+Ctrl+K".action.move-column-to-monitor-up = [ ];
          "Mod+Shift+Ctrl+J".action.move-column-to-monitor-down = [ ];

          # Workspace navigation
          "Mod+Page_Down".action.focus-workspace-down = [ ];
          "Mod+Page_Up".action.focus-workspace-up = [ ];
          "Mod+U".action.focus-workspace-down = [ ];
          "Mod+I".action.focus-workspace-up = [ ];
          "Mod+Ctrl+Page_Down".action.move-column-to-workspace-down = [ ];
          "Mod+Ctrl+Page_Up".action.move-column-to-workspace-up = [ ];
          "Mod+Ctrl+U".action.move-column-to-workspace-down = [ ];
          "Mod+Ctrl+I".action.move-column-to-workspace-up = [ ];
          "Mod+Shift+Page_Down".action.move-workspace-down = [ ];
          "Mod+Shift+Page_Up".action.move-workspace-up = [ ];
          "Mod+Shift+U".action.move-workspace-down = [ ];
          "Mod+Shift+I".action.move-workspace-up = [ ];

          # Mouse wheel workspace switching
          "Mod+WheelScrollDown" = {
            action.focus-workspace-down = [ ];
            cooldown-ms = 150;
          };
          "Mod+WheelScrollUp" = {
            action.focus-workspace-up = [ ];
            cooldown-ms = 150;
          };
          "Mod+Ctrl+WheelScrollDown" = {
            action.move-column-to-workspace-down = [ ];
            cooldown-ms = 150;
          };
          "Mod+Ctrl+WheelScrollUp" = {
            action.move-column-to-workspace-up = [ ];
            cooldown-ms = 150;
          };

          # Mouse wheel column navigation
          "Mod+WheelScrollRight".action.focus-column-right = [ ];
          "Mod+WheelScrollLeft".action.focus-column-left = [ ];
          "Mod+Ctrl+WheelScrollRight".action.move-column-right = [ ];
          "Mod+Ctrl+WheelScrollLeft".action.move-column-left = [ ];
          "Mod+Shift+WheelScrollDown".action.focus-column-right = [ ];
          "Mod+Shift+WheelScrollUp".action.focus-column-left = [ ];
          "Mod+Ctrl+Shift+WheelScrollDown".action.move-column-right = [ ];
          "Mod+Ctrl+Shift+WheelScrollUp".action.move-column-left = [ ];

          # Consume/expel windows
          "Mod+BracketLeft".action.consume-or-expel-window-left = [ ];
          "Mod+BracketRight".action.consume-or-expel-window-right = [ ];
          "Mod+Comma".action.consume-window-into-column = [ ];
          "Mod+Period".action.expel-window-from-column = [ ];

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

          # Move column to workspace
          "Mod+Shift+1".action.move-column-to-workspace = [ 1 ];
          "Mod+Shift+2".action.move-column-to-workspace = [ 2 ];
          "Mod+Shift+3".action.move-column-to-workspace = [ 3 ];
          "Mod+Shift+4".action.move-column-to-workspace = [ 4 ];
          "Mod+Shift+5".action.move-column-to-workspace = [ 5 ];
          "Mod+Shift+6".action.move-column-to-workspace = [ 6 ];
          "Mod+Shift+7".action.move-column-to-workspace = [ 7 ];
          "Mod+Shift+8".action.move-column-to-workspace = [ 8 ];
          "Mod+Shift+9".action.move-column-to-workspace = [ 9 ];

          # Screenshots
          "Mod+Shift+S".action.screenshot = [ ];

          # Miscellaneous
          "Mod+Escape" = {
            action.toggle-keyboard-shortcuts-inhibit = [ ];
            allow-inhibiting = false;
          };
          "Mod+Shift+E".action.quit = [ ];
          "Ctrl+Alt+Delete".action.quit = [ ];
        };

      # Hotkey overlay
      hotkey-overlay = {
        skip-at-startup = true;
      };

      # Prefer no CSD (client-side decorations)
      prefer-no-csd = true;

      # Screenshot path
      screenshot-path = "~/Pictures/Screenshots/Screenshot_%Y-%m-%d %H-%M-%S.png";

      # Animations
      animations = {
        # slowdown = 1.0;
      };
    };
  };
}
