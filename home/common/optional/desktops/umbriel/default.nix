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
#
# Umbriel loads the highest-priority config file *instead of* merging with the
# packaged one, and a [keybinds] table also suppresses the compiled-in defaults.
# Nothing survives that is not declared here, so this module reproduces
# share/umbriel/config.toml's window rules and binds alongside our own. Keep
# them in sync when the package updates; `umbriel msg cheatsheet-open` lists
# what is actually active.
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
  # Must match the binary and the profile names declared in
  # core/zen-browser.nix — `-p` is case-sensitive.
  browser = {
    admin = "work_admin";
    cmd = "zen-beta";
    personal = "personal";
    work = "work";
  };
  # On the work machine Mod+D opens Teams and Mod+B the work profile;
  # elsewhere Discord and the personal profile.
  isWork = hostname == "work";
  # Window and workspace management, spelled with umbriel's action names.
  #
  # Absent because umbriel has no equivalent: tabbed columns, expanding a column
  # to the available width, resetting a window's height, and moving a window to
  # a workspace without following it. Mod+Escape is deliberately left unbound
  # rather than restored to umbriel's default session-quit.
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
    # Not Mod+Shift+Slash: on the Swedish layout `?` is Shift on `+` while
    # `slash` is Shift+7, and umbriel matches both the shifted keysym and the
    # raw one — so a Slash bind would also fire on Mod+Shift+7 and race the
    # workspace bind.
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
    if lib.hasInfix "@" username then
      "env LD_LIBRARY_PATH=${pkgs.sssd}/lib noctalia"
    else
      "noctalia";
  # share/umbriel/config.toml's own binds, plus the vim directions it leaves to
  # the compiled-in defaults. Both need declaring: see the note at the top.
  packagedBinds = {
    "Mod+Ctrl+H" = "column-move-left";
    "Mod+Ctrl+J" = "window-move-down";
    "Mod+Ctrl+K" = "window-move-up";
    "Mod+Ctrl+L" = "column-move-right";
    "Mod+Down" = "window-focus-down";
    # Mod+F fills the width but keeps the bar's struts, Mod+Shift+F genuinely
    # covers everything. Mod+M below is the third variant, which ignores gaps
    # and struts entirely.
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
  # Taken from umbriel's own flake inputs rather than added as an input of ours,
  # so the portal version always matches the compositor it talks to.
  portalPackage = inputs.umbriel.inputs.xdg-desktop-portal-umbriel.packages.${system}.default;
  # Scratchpad: a per-output stash of windows that live outside the workspace
  # strip. Umbriel implements it natively (`umbriel msg --help`, "Scratchpad"),
  # but binds none of it, so the chords are ours.
  #
  # Keyed to follow the Super tier's own logic: bare Super acts on what is on
  # screen (show/hide the stash), Super+Ctrl moves the focused window — the same
  # sense as Super+Ctrl+h/j/k/l — and Super+Alt cycles within what bare Super
  # revealed. Every action is left output-bare, so each monitor keeps its own
  # scratchpad and the chords act on whichever one has focus.
  scratchpadBinds = {
    "Mod+Alt+S" = "scratchpad-focus-next";
    "Mod+Ctrl+S" = "window-toggle-scratchpad";
    "Mod+S" = "scratchpad-toggle";
  };
in

{
  # Screen capture and screen sharing. The backend declares `UseIn=umbriel` and
  # implements ScreenCast + Screenshot, but nothing else can serve them here:
  # routing capture at the gnome backend (as the rest of the config does) sends
  # it to Mutter, which knows nothing about this session.
  home.packages = [ portalPackage ];
  imports = [ inputs.umbriel.homeModules.default ];

  programs.umbriel = {
    enable = true;
    package = inputs.umbriel.packages.${system}.default;

    settings = {
      # Blur and shadows stay at umbriel's defaults (both on). Only the corner
      # radius is overridden: umbriel defaults to 10, and this config uses 12
      # on every window.
      appearance.corner_radius = 12;

      general = {
        # Noctalia is the shell; corectrl manages GPU fan curves.
        autostart = [
          noctaliaCmd
          "corectrl"
        ];

        # Noctalia draws the bar and panels; umbriel's own overlay would double up.
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

        # Umbriel defaults to an empty layout, which falls back to the system
        # default — and this host has no VC keymap set, so it lands on us.
        keyboard.layout = "se";
      };

      # Precedence: the packaged defaults lose to our application chords, which
      # lose to the Noctalia chords documented in README.md. The one casualty is
      # Mod+P — umbriel packages it as window-toggle-pinned, but it is the
      # password manager everywhere else in this config, so it is dropped from
      # packagedBinds above rather than left to be silently overridden.
      keybinds = packagedBinds // navigationBinds // scratchpadBinds // appBinds // noctaliaBinds;

      # share/umbriel/config.toml's rules, which defining any window_rule here
      # would otherwise drop. The first is load-bearing rather than cosmetic:
      # the global blur engine only builds the buffers, and a window or layer
      # rule must opt each surface in, so without it blur is enabled and inert.
      window_rule = [
        {
          blur = true;
          blur_optimized = false;
        }
        {
          default_floating = true;

          default_size = [
            1020
            900
          ];

          match.app_id = "^dev.noctalia.Noctalia$";
        }
        # The screencast source picker.
        {
          default_floating = true;

          default_size = [
            800
            600
          ];

          match.app_id = "^dev.noctalia.UmbrielSharePicker$";
        }
        # Browsers expose no semantic PiP role or global position control.
        {
          default_floating = true;
          default_maximize = false;

          default_position = {
            anchor = "bottom_right";
            x = 20;
            y = 20;
          };

          match.title = "^(Picture-in-Picture|Picture in picture)$";
        }
        # Keep Steam notification toasts in the bottom-right corner without
        # stealing focus, and pin them so workspace switches do not hide them.
        {
          default_focused = false;
          default_pinned = true;

          default_position = {
            anchor = "bottom_right";
            x = 0;
            y = 0;
          };

          match.title = "^notificationtoasts_.+_desktop";
        }
        # Umbriel has no default-size equivalent for tiled windows, but the
        # output is already 2560x1440 and the rule only ever existed to make WoW
        # open fullscreen at native resolution.
        {
          default_fullscreen = true;
          match.title = "^World of Warcraft$";
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
