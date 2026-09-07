{
  lib,
  config,
  pkgs,
  ...
}:

# Appearance for Ubuntu's GDM login screen.
#
# GDM's greeter runs as the `gdm` user, which cannot read anything under
# /home/drakkir — hosts/common/core tmpfiles pins that directory to 0700. So
# every asset referenced here has to live somewhere world-readable: the Nix
# store for the wallpaper source and cursor theme, /var/lib for the generated
# background.
#
# Settings reach the greeter through Debian's dconf keyfile directory:
# /usr/share/gdm/dconf/ holds 00-upstream-settings and 90-debian-settings (a
# symlink to /etc/gdm3/greeter.dconf-defaults). gdm.service recompiles that
# directory into /var/lib/gdm3/greeter-dconf-defaults on every start via its
# ExecStartPre=/usr/share/gdm/generate-config. Dropping a higher-numbered file
# in beside them overrides both, and leaves /etc/gdm3 untouched for apt.
#
# The background keys are Ubuntu-specific: com.ubuntu.login-screen is a distro
# patch read by /usr/lib/gnome-shell/libshell-14.so. Upstream GNOME paints the
# login background from the theme stylesheet instead, which is why the usual
# advice is to recompile gnome-shell-theme.gresource — not needed here, and
# that approach would be clobbered by every gnome-shell update.
#
# ── Why the background is composited at runtime ──────────────────────────────
# gnome-shell sets the background style on `_lockDialogGroup`, a child of
# `screenShieldGroup`, which spans the *entire* virtual desktop rather than one
# actor per monitor. With mixed-resolution outputs that makes `background-size`
# useless on its own: on a 1920x1080 + 2560x1440 desktop the stage is 4480x1440
# (3.11:1), so `cover` scales a 16:9 source by 2.33x and crops away most of it,
# while `contain` letterboxes it across the seam between the screens.
#
# So we build a stage-sized image with each monitor's region framed
# individually and hand it over at native size (`auto` + `no-repeat`).
#
# That has to happen at runtime rather than build time, because the monitor set
# is not a property of the configuration — a laptop docks and undocks. The
# compositing script reads /sys/class/drm just before gdm starts and sizes the
# canvas to whatever is actually connected. A single-monitor machine therefore
# needs no configuration at all.
#
# The one thing sysfs cannot tell us is left-to-right order, and mutter's
# arrangement does not necessarily match the compositor's: on terra, niri puts
# DP-1 first while GDM puts DP-2 first. `myConfig.gdm.outputOrder` exists purely
# to pin that, and is only needed when outputs differ in resolution — with a
# single output, or several identical ones, order cannot change the result.
let
  cfg = config.myConfig.gdm;
in

{
  config = {
    # Keys use dconf paths (slashes), not GSettings ids (dots).
    #
    # The background is a fixed /var/lib path rather than a store path, because
    # the image is regenerated at runtime; baking a store path here would mean
    # the keyfile had to change every time the monitor layout did.
    environment.etc."gdm-appearance-95".text = ''
      [com/ubuntu/login-screen]
      background-picture-uri='file:///var/lib/gdm-appearance/background.png'
      background-repeat='no-repeat'
      background-size='auto'

      [org/gnome/desktop/interface]
      color-scheme='prefer-dark'
      cursor-size=${toString cfg.cursorSize}
      cursor-theme='${cfg.cursorTheme}'

      [org/gnome/login-screen]
      logo=""
    '';

    systemd = {
      services.gdm-appearance = {
        after = [ "sysinit-reactivation.target" ];
        before = [ "gdm.service" ];
        description = "Compose the GDM login background for the connected monitors";

        script = ''
          export MAGICK=${pkgs.imagemagick}/bin/magick
          export OUTPUT_ORDER=${lib.escapeShellArg (lib.concatStringsSep " " cfg.outputOrder)}
          export WALLPAPER=${cfg.wallpaper}

          exec ${pkgs.bash}/bin/bash ${./gdm/compose-background.sh}
        '';

        serviceConfig = {
          RemainAfterExit = true;
          Type = "oneshot";
        };

        # graphical.target so it runs before gdm at boot; system-manager.target
        # so `just system` applies changes without waiting for a reboot.
        wantedBy = [
          "graphical.target"
          "system-manager.target"
        ];
      };

      # 95- sorts after Debian's 90-debian-settings, so these win. polkit and
      # dconf only read from /usr/share, never a store path, so both of these
      # have to be linked into place — same reasoning as umbriel-portal.nix.
      tmpfiles.settings."15-gdm-appearance" = {
        "/usr/share/gdm/dconf/95-appearance"."L+".argument = "/etc/gdm-appearance-95";

        "/usr/share/icons/${cfg.cursorTheme}"."L+".argument =
          "${pkgs.bibata-cursors}/share/icons/${cfg.cursorTheme}";
      };
    };
  };

  options.myConfig.gdm = {
    cursorSize = lib.mkOption {
      default = 24;
      description = "Cursor size on the login screen.";
      type = lib.types.int;
    };

    cursorTheme = lib.mkOption {
      default = "Bibata-Modern-Ice";

      description = ''
        Cursor theme for the login screen. Must exist in pkgs.bibata-cursors;
        the copy in ~/.icons is unreadable to the gdm user.
      '';

      type = lib.types.str;
    };

    outputOrder = lib.mkOption {
      default = [ ];

      description = ''
        Connector names in left-to-right order as GDM arranges them, for
        example [ "DP-2" "DP-1" ]. Connected outputs not listed here are
        appended alphabetically.

        Only matters when the connected outputs differ in resolution: with one
        output, or several identical ones, the ordering cannot change the
        composited result. Note this is GDM's arrangement, which is not
        necessarily the same as the one in your compositor's config.
      '';

      example = [
        "DP-2"
        "DP-1"
      ];

      type = lib.types.listOf lib.types.str;
    };

    wallpaper = lib.mkOption {
      description = "Source image, framed per monitor onto a desktop-sized canvas.";
      type = lib.types.path;
    };
  };
}
