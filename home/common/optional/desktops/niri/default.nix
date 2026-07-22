{
  config,
  hostname,
  inputs,
  lib,
  pkgs,
  username,
  ...
}:

let
  # Conditionally use Noctalia keybindings
  kb = config.myConfig.programs.noctalia.keybindings or { };
  noctaliaEnabled = kb != { };

  # On AD domain machines (username contains "@"), Nix glibc can't resolve
  # the fully-qualified username via SSSD because it lacks libnss_sss.so.2.
  # We expose Nix's own sssd NSS module via LD_LIBRARY_PATH so getpwnam_r
  # can resolve domain usernames, which then pass through to pam_sss for auth.
  needsNssFixup = lib.hasInfix "@" username;
  noctaliaSpawn =
    if needsNssFixup then
      { sh = "LD_LIBRARY_PATH=${pkgs.sssd}/lib exec noctalia"; }
    else
      { command = [ "noctalia" ]; };

  # Swap browser profile shortcuts based on host
  isWorkHost = hostname == "work";
  browserPersonalProfile = "personal";
  browserWorkProfile = "work";
in

{
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
  imports = [ inputs.niri.homeModules.niri ];
  # Configure Niri window manager
  programs.niri = {
    enable = true;
    package = pkgs.niri;
    settings = {
      # Animations
      animations = {
        # slowdown = 1.0;
      };
      # Keybindings
      binds =
        with config.lib.niri.actions;
        lib.optionalAttrs noctaliaEnabled {
          "${kb.brightnessDown.niri.key}".action.spawn = kb.brightnessDown.niri.action;
          # Brightness controls
          "${kb.brightnessUp.niri.key}".action.spawn = kb.brightnessUp.niri.action;
          # NOTE: no calendar bind — Noctalia v5 has no calendar IPC command.
          "${kb.clipboard.niri.key}".action.spawn = kb.clipboard.niri.action;
          # Noctalia keybindings (only if enabled)
          "${kb.launcher.niri.key}".action.spawn = kb.launcher.niri.action;
          "${kb.lockScreen.niri.key}".action.spawn = kb.lockScreen.niri.action;
          "${kb.micMute.niri.key}".action.spawn = kb.micMute.niri.action;
          "${kb.volumeDown.niri.key}".action.spawn = kb.volumeDown.niri.action;
          "${kb.volumeMute.niri.key}".action.spawn = kb.volumeMute.niri.action;
          # Volume controls
          "${kb.volumeUp.niri.key}".action.spawn = kb.volumeUp.niri.action;
        }
        // {
          "Ctrl+Alt+Delete".action.quit = [ ];
          "Mod+0".action.focus-workspace = [ 10 ];
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
          "Mod+B".action.spawn = [
            "zen-beta"
            "-p"
            (if isWorkHost then browserWorkProfile else browserPersonalProfile)
          ];
          # Consume/expel windows
          "Mod+BracketLeft".action.consume-or-expel-window-left = [ ];
          "Mod+BracketRight".action.consume-or-expel-window-right = [ ];
          "Mod+C".action.center-column = [ ];
          "Mod+Comma".action.consume-window-into-column = [ ];
          "Mod+Ctrl+C".action.center-visible-columns = [ ];
          "Mod+Ctrl+Down".action.move-window-down = [ ];
          "Mod+Ctrl+F".action.expand-column-to-available-width = [ ];
          "Mod+Ctrl+H".action.move-column-left = [ ];
          "Mod+Ctrl+I".action.move-column-to-workspace-up = [ ];
          "Mod+Ctrl+J".action.move-window-down = [ ];
          "Mod+Ctrl+K".action.move-window-up = [ ];
          "Mod+Ctrl+L".action.move-column-right = [ ];
          # Window movement
          "Mod+Ctrl+Left".action.move-column-left = [ ];
          "Mod+Ctrl+Page_Down".action.move-column-to-workspace-down = [ ];
          "Mod+Ctrl+Page_Up".action.move-column-to-workspace-up = [ ];
          "Mod+Ctrl+R".action.reset-window-height = [ ];
          "Mod+Ctrl+Right".action.move-column-right = [ ];
          "Mod+Ctrl+Shift+B".action.spawn = [
            "zen-beta"
            "-p"
            "Work_Admin"
          ];
          "Mod+Ctrl+Shift+WheelScrollDown".action.move-column-right = [ ];
          "Mod+Ctrl+Shift+WheelScrollUp".action.move-column-left = [ ];
          "Mod+Ctrl+U".action.move-column-to-workspace-down = [ ];
          "Mod+Ctrl+Up".action.move-window-up = [ ];
          "Mod+Ctrl+WheelScrollDown" = {
            action.move-column-to-workspace-down = [ ];
            cooldown-ms = 150;
          };
          "Mod+Ctrl+WheelScrollLeft".action.move-column-left = [ ];
          "Mod+Ctrl+WheelScrollRight".action.move-column-right = [ ];
          "Mod+Ctrl+WheelScrollUp" = {
            action.move-column-to-workspace-up = [ ];
            cooldown-ms = 150;
          };
          "Mod+D".action.spawn = [ "discord" ];
          "Mod+Down".action.focus-window-down = [ ];
          # Applications
          "Mod+E".action.spawn = [ "nautilus" ];
          "Mod+Equal".action.set-column-width = [ "+10%" ];
          # Miscellaneous
          "Mod+Escape" = {
            action.toggle-keyboard-shortcuts-inhibit = [ ];
            allow-inhibiting = false;
          };
          "Mod+F".action.maximize-column = [ ];
          "Mod+H".action.focus-column-left = [ ];
          "Mod+I".action.focus-workspace-up = [ ];
          "Mod+J".action.focus-window-down = [ ];
          "Mod+K".action.focus-window-up = [ ];
          "Mod+L".action.focus-column-right = [ ];
          # Focus movement
          "Mod+Left".action.focus-column-left = [ ];
          # Finer adjustments
          "Mod+Minus".action.set-column-width = [ "-10%" ];
          # Overview and hotkeys
          "Mod+O" = {
            action.toggle-overview = [ ];
            repeat = false;
          };
          "Mod+P".action.spawn = [ "proton-pass" ];
          # Workspace navigation
          "Mod+Page_Down".action.focus-workspace-down = [ ];
          "Mod+Page_Up".action.focus-workspace-up = [ ];
          "Mod+Period".action.expel-window-from-column = [ ];
          # Window management
          "Mod+Q" = {
            action.close-window = [ ];
            repeat = false;
          };
          # Column width presets
          "Mod+R".action.switch-preset-column-width = [ ];
          # Terminal
          "Mod+Return".action.spawn = [
            "env"
            "GTK_IM_MODULE=simple"
            "ghostty"
          ];
          "Mod+Right".action.focus-column-right = [ ];
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
          "Mod+Shift+B".action.spawn = [
            "zen-beta"
            "-p"
            (if isWorkHost then browserPersonalProfile else browserWorkProfile)
          ];
          "Mod+Shift+Ctrl+Down".action.move-column-to-monitor-down = [ ];
          "Mod+Shift+Ctrl+H".action.move-column-to-monitor-left = [ ];
          "Mod+Shift+Ctrl+J".action.move-column-to-monitor-down = [ ];
          "Mod+Shift+Ctrl+K".action.move-column-to-monitor-up = [ ];
          "Mod+Shift+Ctrl+L".action.move-column-to-monitor-right = [ ];
          # Move to monitor
          "Mod+Shift+Ctrl+Left".action.move-column-to-monitor-left = [ ];
          "Mod+Shift+Ctrl+Right".action.move-column-to-monitor-right = [ ];
          "Mod+Shift+Ctrl+Up".action.move-column-to-monitor-up = [ ];
          "Mod+Shift+Down".action.focus-monitor-down = [ ];
          "Mod+Shift+E".action.quit = [ ];
          "Mod+Shift+Equal".action.set-window-height = [ "+10%" ];
          "Mod+Shift+F".action.fullscreen-window = [ ];
          "Mod+Shift+H".action.focus-monitor-left = [ ];
          "Mod+Shift+I".action.move-workspace-up = [ ];
          "Mod+Shift+J".action.focus-monitor-down = [ ];
          "Mod+Shift+K".action.focus-monitor-up = [ ];
          "Mod+Shift+L".action.focus-monitor-right = [ ];
          # Monitor focus
          "Mod+Shift+Left".action.focus-monitor-left = [ ];
          "Mod+Shift+Minus".action.set-window-height = [ "-10%" ];
          "Mod+Shift+Page_Down".action.move-workspace-down = [ ];
          "Mod+Shift+Page_Up".action.move-workspace-up = [ ];
          "Mod+Shift+R".action.switch-preset-window-height = [ ];
          "Mod+Shift+Return".action.spawn = [ "kitty" ];
          "Mod+Shift+Right".action.focus-monitor-right = [ ];
          # Screenshots
          "Mod+Shift+S".action.screenshot = [ ];
          "Mod+Shift+Slash".action.show-hotkey-overlay = [ ];
          "Mod+Shift+U".action.move-workspace-down = [ ];
          "Mod+Shift+Up".action.focus-monitor-up = [ ];
          "Mod+Shift+WheelScrollDown".action.focus-column-right = [ ];
          "Mod+Shift+WheelScrollUp".action.focus-column-left = [ ];
          "Mod+T".action.toggle-window-floating = [ ];
          "Mod+U".action.focus-workspace-down = [ ];
          "Mod+Up".action.focus-window-up = [ ];
          "Mod+W".action.toggle-column-tabbed-display = [ ];
          # Mouse wheel workspace switching
          "Mod+WheelScrollDown" = {
            action.focus-workspace-down = [ ];
            cooldown-ms = 150;
          };
          "Mod+WheelScrollLeft".action.focus-column-left = [ ];
          # Mouse wheel column navigation
          "Mod+WheelScrollRight".action.focus-column-right = [ ];
          "Mod+WheelScrollUp" = {
            action.focus-workspace-up = [ ];
            cooldown-ms = 150;
          };
        };
      # Hotkey overlay
      hotkey-overlay = {
        skip-at-startup = true;
      };
      # Input configuration
      input = {
        focus-follows-mouse = {
          enable = true;
          max-scroll-amount = "10%";
        };
        keyboard = {
          xkb = {
            layout = "se";
          };
        };
        touchpad = {
          natural-scroll = false;
          tap = true;
        };
      };
      # Layout configuration
      layout = {
        always-center-single-column = true;
        # Border configuration (disabled by default)
        border = {
          enable = false;
        };
        center-focused-column = "on-overflow";
        default-column-width = {
          proportion = 0.5;
        };
        # Focus ring configuration
        focus-ring = {
          active.color = "#7fc8ff";
          inactive.color = "#505050";
          width = 4.0;
        };
        gaps = 16;
        preset-column-widths = [
          { proportion = 0.33333; }
          { proportion = 0.5; }
          { proportion = 0.66667; }
        ];
      };
      # Output configuration
      outputs = {
        "DP-1" = {
          mode = {
            height = 1080;
            refresh = 119.982;
            width = 1920;
          };
          position = {
            x = 0;
            y = 0;
          };
        };
        "DP-2" = {
          mode = {
            height = 1440;
            refresh = 143.998;
            width = 2560;
          };
          position = {
            x = 1920;
            y = 0;
          };
        };
        "eDP-1" = {
          mode = {
            height = 1080;
            refresh = 60.00;
            width = 1920;
          };
          position = {
            x = 0;
            y = 0;
          };
          scale = 1.0;
        };
      };
      # Prefer no CSD (client-side decorations)
      prefer-no-csd = true;
      # Screenshot path
      screenshot-path = "~/Pictures/Screenshots/Screenshot_%Y-%m-%d %H-%M-%S.png";
      # Spawn applications at startup
      spawn-at-startup = [
        { command = [ "corectrl" ]; }
        # { command = [ "proton-pass" ]; } # can not start minimized.
      ]
      ++ lib.optionals noctaliaEnabled [ noctaliaSpawn ];
      # Window rules
      window-rules = [
        # Enable rounded corners for all windows
        {
          clip-to-geometry = true;
          geometry-corner-radius = {
            bottom-left = 12.0;
            bottom-right = 12.0;
            top-left = 12.0;
            top-right = 12.0;
          };
        }
        # World of Warcraft: 1440p fullscreen
        {
          default-column-width = {
            fixed = 2560;
          };
          default-window-height = {
            fixed = 1440;
          };
          matches = [ { title = "^World of Warcraft$"; } ];
          open-fullscreen = true;
        }
      ];
    };
  };
  # Import niri systemd service from the package
  # The niri home module doesn't automatically set this up, so we do it manually
  # Note: This service is started by niri-session, not automatically
  systemd.user.services.niri = {
    Install = {
      # Don't auto-start - niri-session handles starting this service
      WantedBy = lib.mkForce [ ];
    };
    Service = {
      ExecStart = "${config.programs.niri.package}/bin/niri --session";
      Slice = "session.slice";
      Type = "notify";
    };
    Unit = {
      After = "graphical-session-pre.target";
      Before = "graphical-session.target";
      BindsTo = "graphical-session.target";
      Description = "A scrollable-tiling Wayland compositor";
      Wants = [
        "graphical-session-pre.target"
        "xdg-desktop-autostart.target"
      ];
    };
  };
  # X11 System Tray to StatusNotifierItem bridge
  # xtrayhide captures X11 tray icons, hides them, and exposes them as SNI
  # This prevents the black container window issue with Wine/Battle.net
  systemd.user.services.xtrayhide = {
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.xtrayhide}/bin/xtrayhide";
      Restart = "on-failure";
      RestartSec = 3;
      Type = "simple";
    };
    Unit = {
      After = [ "graphical-session.target" ];
      ConditionEnvironment = "WAYLAND_DISPLAY";
      Description = "X11 System Tray to StatusNotifierItem bridge (with hidden windows)";
      PartOf = [ "graphical-session.target" ];
    };
  };
  systemd.user.targets.niri-shutdown = {
    Unit.Description = "niri shutdown target";
  };
}
