{
  lib,
  config,
  pkgs,
  hostname,
  inputs,
  system,
  username,
  ...
}:

# Umbriel — noctalia's own wlroots compositor.
let
  appBinds = {
    "Mod+B" = "spawn:${browser.cmd} -p ${if isWork then browser.work else browser.personal}";
    # Universal clipboard: synthesise the legacy CUA chords with wtype, which
    # both terminals and GTK/Qt apps honour, so one key works everywhere.
    "Mod+C" = "spawn:wtype -M ctrl -k Insert -m ctrl";
    "Mod+Ctrl+Shift+B" = "spawn:${browser.cmd} -p ${browser.admin}";
    "Mod+D" = "spawn:${if isWork then "teams-for-linux" else "discord"}";
    "Mod+E" = "spawn:nautilus";
    "Mod+P" = "spawn:proton-pass";
    "Mod+Return" = "spawn:env GTK_IM_MODULE=simple ghostty";
    "Mod+Shift+B" = "spawn:${browser.cmd} -p ${if isWork then browser.personal else browser.work}";
    # Umbriel has no screenshot action of its own, so use the shell's — which
    # is what draws the picker anyway.
    "Mod+Shift+S" = "spawn:noctalia msg screenshot-region";
    "Mod+V" = "spawn:wtype -M shift -k Insert -m shift";
  };
  browser = {
    admin = "work_admin";
    cmd = "zen-beta";
    personal = "personal";
    work = "work";
  };
  # On the work machine Mod+D opens Teams and Mod+B the work profile;
  # elsewhere Discord and the personal profile.
  isWork = hostname == "work";
  navigationBinds = {
    "Mod+BracketLeft" = "window-consume-or-expel-left";
    "Mod+BracketRight" = "window-consume-or-expel-right";
    "Mod+Comma" = "window-consume-left";
    "Mod+Ctrl+C" = "column-center";
    "Mod+Ctrl+I" = "column-move-to-workspace-previous";
    "Mod+Ctrl+Page_Down" = "column-move-to-workspace-next";
    "Mod+Ctrl+Page_Up" = "column-move-to-workspace-previous";
    "Mod+Ctrl+Shift+H" = "column-move-to-output-left";
    "Mod+Ctrl+Shift+J" = "column-move-to-output-down";
    "Mod+Ctrl+Shift+K" = "column-move-to-output-up";
    "Mod+Ctrl+Shift+L" = "column-move-to-output-right";
    "Mod+Ctrl+Shift+WheelDown" = "column-move-right";
    "Mod+Ctrl+Shift+WheelUp" = "column-move-left";
    "Mod+Ctrl+U" = "column-move-to-workspace-next";
    "Mod+Equal" = "window-modify-width:0.1";
    "Mod+I" = "workspace-previous";
    "Mod+Minus" = "window-modify-width:-0.1";
    "Mod+Page_Down" = "workspace-next";
    "Mod+Page_Up" = "workspace-previous";
    "Mod+Period" = "window-consume-right";
    "Mod+R" = "window-cycle-width";
    "Mod+Shift+E" = "session-quit";
    "Mod+Shift+Equal" = "window-modify-height:0.1";
    "Mod+Shift+H" = "output-focus-left";
    "Mod+Shift+I" = "workspace-move-up";
    "Mod+Shift+J" = "output-focus-down";
    "Mod+Shift+K" = "output-focus-up";
    "Mod+Shift+L" = "output-focus-right";
    "Mod+Shift+Minus" = "window-modify-height:-0.1";
    "Mod+Shift+Page_Down" = "workspace-move-down";
    "Mod+Shift+Page_Up" = "workspace-move-up";
    "Mod+Shift+R" = "window-cycle-height";
    "Mod+Shift+U" = "workspace-move-down";
    "Mod+Shift+WheelDown" = "window-focus-right";
    "Mod+Shift+WheelUp" = "window-focus-left";
    "Mod+Shift+question" = "cheatsheet-toggle";
    "Mod+U" = "workspace-next";
    "Mod+WheelDown" = "workspace-next";
    "Mod+WheelUp" = "workspace-previous";
  }
  # Mod+N switches to workspace N, Mod+Shift+N takes the column along.
  // lib.mergeAttrsList (
    map (n: {
      "Mod+${n}" = "workspace-switch:${n}";
      "Mod+Shift+${n}" = "column-move-to-workspace:${n}";
    }) (map toString (lib.range 1 9))
  );
  # Every Noctalia bind that declares an umbriel variant, re-keyed by chord.
  noctaliaBinds = lib.mapAttrs' (_: v: lib.nameValuePair v.umbriel.key v.umbriel.action) (
    lib.filterAttrs (_: v: v ? umbriel) (config.myConfig.programs.noctalia.keybindings or { })
  );
  # On AD domain machines (username contains "@") Nix's glibc lacks
  # libnss_sss.so.2, so it cannot resolve the fully-qualified username via SSSD.
  noctaliaCmd =
    if lib.hasInfix "@" username then "env LD_LIBRARY_PATH=${pkgs.sssd}/lib noctalia" else "noctalia";
  # share/umbriel/config.toml's own binds, plus the vim directions it leaves to
  # the compiled-in defaults. Both need declaring: see the note at the top.
  packagedBinds = {
    "Mod+Ctrl+H" = "column-move-left";
    "Mod+Ctrl+J" = "window-move-down";
    "Mod+Ctrl+K" = "window-move-up";
    "Mod+Ctrl+L" = "column-move-right";
    "Mod+Down" = "window-focus-down";
    "Mod+F" = "window-toggle-maximize";
    "Mod+H" = "window-focus-left";
    "Mod+J" = "window-focus-down";
    "Mod+K" = "window-focus-up";
    "Mod+L" = "window-focus-right";
    "Mod+Left" = "window-focus-left";
    "Mod+M" = "window-toggle-maximize-to-edges";

    "Mod+O" = {
      action = "overview-toggle";
      repeat = false;
    };

    "Mod+Q" = "window-close";
    "Mod+Right" = "window-focus-right";
    "Mod+Shift+F" = "window-toggle-fullscreen";
    "Mod+Shift+T" = "window-focus-switch-floating";
    "Mod+T" = "window-toggle-floating";
    "Mod+Up" = "window-focus-up";
  };
  portalPackage = inputs.umbriel.inputs.xdg-desktop-portal-umbriel.packages.${system}.default;
  scratchpadBinds = {
    "Mod+Alt+S" = "scratchpad-focus-next";
    "Mod+Ctrl+S" = "window-toggle-scratchpad";
    "Mod+S" = "scratchpad-toggle";
  };
in

{
  home.packages = [ portalPackage ];

  imports = [
    inputs.umbriel.homeModules.default
    ../portals.nix
    ../xtrayhide.nix
  ];

  programs.umbriel = {
    enable = true;
    package = inputs.umbriel.packages.${system}.default;

    settings = {
      animation.scratchpad = {
        enabled = true;
        scale = 0.8;
      };

      appearance.corner_radius = 12;

      general = {
        autostart = [
          noctaliaCmd
          "corectrl"
        ];

        show_cheatsheet = false;
      };

      input = {
        # Focus follows the mouse, but capped: do not steal focus on hover if
        # revealing the window would scroll more than a tenth of a viewport.
        # umbriel expresses the limit in viewport widths, so 0.1 is 10%.
        focus = {
          follows_mouse = true;
          follows_mouse_max_scroll = 0.1;
        };

        keyboard.layout = "se";
      };

      keybinds = packagedBinds // navigationBinds // scratchpadBinds // appBinds // noctaliaBinds;

      layout = {
        gap = 8;
        scrolling = {
          default_width_fraction = 0.5;
        };
        width_presets = [
          0.33333
          0.5
          0.66667
        ];
      };

      window_rule = [
        {
          blur = true;
          blur_optimized = false;
        }
        {
          match.app_id = "^dev.noctalia.Noctalia$";
          default_floating = true;
          default_size = [
            1020
            900
          ];
        }
        # The screencast source picker.
        {
          match.app_id = "^dev.noctalia.UmbrielSharePicker$";
          default_floating = true;
          default_size = [
            800
            600
          ];
        }
        # Browsers expose no semantic PiP role or global position control.
        {
          match.title = "^(Picture-in-Picture|Picture in picture)$";
          default_floating = true;
          default_maximize = false;

          default_position = {
            anchor = "bottom_right";
            x = 20;
            y = 20;
          };
        }
        # Keep Steam notification toasts in the bottom-right corner without
        # stealing focus, and pin them so workspace switches do not hide them.
        {
          match.title = "^notificationtoasts_.+_desktop";
          default_focused = false;
          default_pinned = true;

          default_position = {
            anchor = "bottom_right";
            x = 0;
            y = 0;
          };

        }
        # Battle.net's tray context menu, dragged back under the bar's tray.
        {
          match.title = "^Battle\\.net$";
          default_position = {
            anchor = "top_right";
            x = 220;
            y = 0;
          };
        }
        {
          default_fullscreen = true;
          match.title = "^World of Warcraft$";
        }
        {
          default_width = 1.0;
          match.app_id = "^zen-beta$";
        }
        {
          default_width = 1.0;
          match.is_alone = true;
        }
        {
          default_width = 0.5;
          match.is_alone = false;
        }
      ];
    };
  };

  # The package ships its units in share/systemd/user, which the systemd *user*
  # manager does not scan on non-NixOS. `start-umbriel` (what the display
  # manager runs) then fails at `systemctl --user --wait start umbriel.service`
  # and the session dies at the login screen, while launching the binary by hand
  # from a TTY still works because that path never touches systemd.
  #
  # Re-declared here so home-manager links them into ~/.config/systemd/user.
  # Keep in sync with share/systemd/user/ in the package.
  systemd.user = {
    services = {
      umbriel = {
        Install = {
          # Started by start-umbriel, never socket/target activated.
          WantedBy = lib.mkForce [ ];
        };

        Service = {
          ExecStart = "${config.programs.umbriel.package}/bin/umbriel";
          Slice = "session.slice";
          Type = "simple";
        };

        Unit = {
          After = "graphical-session-pre.target";
          Before = "umbriel-session.target";
          Description = "Umbriel Wayland compositor";
          Documentation = "https://github.com/noctalia-dev/umbriel";
          PartOf = "umbriel-session.target";
          Wants = "graphical-session-pre.target";
        };
      };

      # Same non-NixOS problem as the compositor units below: the backend's
      # D-Bus service file activates it via `SystemdService=`, and that unit
      # ships in share/systemd/user where the user manager never looks. Without
      # it the bus name is unactivatable and xdg-desktop-portal omits ScreenCast
      # and Screenshot entirely — screen sharing fails with no obvious error.
      xdg-desktop-portal-umbriel = {
        Service = {
          BusName = "org.freedesktop.impl.portal.desktop.umbriel";
          ExecStart = "${portalPackage}/libexec/xdg-desktop-portal-umbriel";
          Restart = "on-failure";
          RestartSec = "5s";
          Type = "dbus";
        };

        Unit = {
          After = "graphical-session.target";
          ConditionEnvironment = "WAYLAND_DISPLAY";
          Description = "Portal backend (umbriel)";
          PartOf = "graphical-session.target";
          StartLimitIntervalSec = 0;
        };
      };
    };

    targets = {
      umbriel-session.Unit = {
        After = "graphical-session-pre.target";
        Before = "xdg-desktop-autostart.target";
        BindsTo = "graphical-session.target";
        Description = "Umbriel compositor session";

        Wants = [
          "graphical-session.target"
          "xdg-desktop-autostart.target"
        ];
      };

      umbriel-shutdown.Unit = {
        After = [
          "graphical-session.target"
          "graphical-session-pre.target"
        ];

        Conflicts = [
          "graphical-session.target"
          "graphical-session-pre.target"
        ];

        DefaultDependencies = false;
        Description = "Shutdown running Umbriel session";
        StopWhenUnneeded = true;
      };
    };
  };

  # GTK/libadwaita apps (Bottles, and every flatpak) learn the dark-mode
  # preference from the portal Settings API, not from the compositor. The gtk
  # backend implements it but declares `UseIn=gnome`, and umbriel ships no
  # portals.conf overriding that — so without this nothing answers Settings and
  # apps silently fall back to light despite gsettings reporting prefer-dark.
  xdg.configFile."xdg-desktop-portal/umbriel-portals.conf".text = ''
    [preferred]
    default=gnome;gtk;
    org.freedesktop.impl.portal.Access=gtk;
    org.freedesktop.impl.portal.Notification=gtk;
    org.freedesktop.impl.portal.ScreenCast=umbriel;
    org.freedesktop.impl.portal.Screenshot=umbriel;
    org.freedesktop.impl.portal.Secret=gnome-keyring;
  '';
}
