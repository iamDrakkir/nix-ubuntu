{ pkgs, ... }:

# Appearance for Ubuntu's GDM login screen.
#
# GDM's greeter runs as the `gdm` user, which cannot read anything under
# /home/drakkir — hosts/common/core tmpfiles pins that directory to 0700. So
# every asset referenced here has to live somewhere world-readable. The Nix
# store is, which is why the wallpaper is committed alongside this module and
# the cursor theme comes from nixpkgs rather than the copy in ~/.icons.
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
# ── Why the wallpaper is composited ──────────────────────────────────────────
# gnome-shell sets the background style on `_lockDialogGroup`, a child of
# `screenShieldGroup`, which spans the *entire* virtual desktop rather than one
# actor per monitor. With mixed-resolution outputs that makes `background-size`
# useless on its own: this desktop is 4480x1440 (3.11:1), so `cover` scales a
# 16:9 source by 2.33x and crops away most of it, and `contain` letterboxes it
# across the seam between the two screens.
#
# Instead, build a single stage-sized image with each monitor's region framed
# individually, then hand it to the greeter at native size (`auto` +
# `no-repeat`) so it lands 1:1 on the desktop.
#
# NOTE: `outputs` below must match the greeter's actual monitor arrangement,
# which is NOT the same as niri's. niri places DP-1 (1920x1080) at x=0 and
# DP-2 (2560x1440) at x=1920; GDM orders them the other way round, so the
# regions here are deliberately mirrored relative to dotfiles/niri/config.kdl.
# Verified empirically — the first attempt used niri's order and came out with
# the two screens' backgrounds swapped.
#
# If you move a monitor or change a resolution, update this list — a mismatch
# shows up as the background being swapped, offset, or letterboxed.
let
  # Composite a stage-sized background: each region is scaled to cover its own
  # monitor (^ resize) and centre-cropped to that monitor's exact size, then
  # placed at the monitor's position on a black canvas.
  #
  # `-gravity NorthWest` before each -geometry is load-bearing. ImageMagick's
  # gravity is global rather than scoped to the \( \) group, so the `center`
  # used for the crop otherwise leaks out and makes -geometry offsets relative
  # to the canvas centre — which silently misplaces every region.
  background =
    pkgs.runCommand "gdm-background.png"
      {
        nativeBuildInputs = [ pkgs.imagemagick ];
      }
      ''
        magick -size ${toString stageWidth}x${toString stageHeight} xc:black \
          ${
            pkgs.lib.concatMapStringsSep " \\\n  " (o: ''
              \( ${source} -resize ${toString o.width}x${toString o.height}^ \
                 -gravity center -extent ${toString o.width}x${toString o.height} \) \
              -gravity NorthWest -geometry +${toString o.x}+${toString o.y} -composite'') outputs
          } \
          -depth 8 "$out"
      '';

  cursorSize = 24;
  cursorTheme = "Bibata-Modern-Ice";

  # Keys use dconf paths (slashes), not GSettings ids (dots).
  greeterDconf = pkgs.writeText "95-appearance" ''
    [com/ubuntu/login-screen]
    background-picture-uri='file://${background}'
    background-repeat='no-repeat'
    background-size='auto'

    [org/gnome/desktop/interface]
    color-scheme='prefer-dark'
    cursor-size=${toString cursorSize}
    cursor-theme='${cursorTheme}'

    [org/gnome/login-screen]
    logo=""
  '';

  outputs = [
    # DP-2 (2560x1440) is the left-hand screen as far as GDM is concerned.
    {
      height = 1440;
      width = 2560;
      x = 0;
      y = 0;
    }
    # DP-1 (1920x1080), top-aligned, to its right.
    {
      height = 1080;
      width = 1920;
      x = 2560;
      y = 0;
    }
  ];

  source = ./gdm/background.png;
  stageHeight = 1440;
  stageWidth = 4480;
in

{
  systemd = {
    # gdm regenerates the database itself on start, but restarting gdm would
    # kill the running session. Compiling here means the new settings are in
    # place for the next time the greeter is shown.
    services.gdm-appearance = {
      after = [ "sysinit-reactivation.target" ];
      description = "Compile the GDM greeter dconf database with local appearance settings";

      script = ''
        if [ ! -e /usr/share/gdm/dconf/95-appearance ]; then
          echo "Error: /usr/share/gdm/dconf/95-appearance missing; tmpfiles did not run."
          exit 1
        fi

        # generate-config is Debian's own script and expects host tooling:
        # setsid and setpriv (util-linux), plus dconf and pkill. system-manager
        # gives units a Nix-only PATH (coreutils, findutils, gnugrep, gnused,
        # systemd-minimal), so without this the script exits 127 on setsid.
        #
        # Host PATH rather than pkgs.util-linux on purpose: dconf must be the
        # host binary, since it writes the host's own database format into
        # /var/lib/gdm3.
        export PATH=/usr/sbin:/usr/bin:/sbin:/bin

        /usr/share/gdm/generate-config
        echo "✓ recompiled /var/lib/gdm3/greeter-dconf-defaults"
      '';

      serviceConfig = {
        RemainAfterExit = true;
        Type = "oneshot";
      };

      wantedBy = [ "system-manager.target" ];
    };

    # 95- sorts after Debian's 90-debian-settings, so these win.
    tmpfiles.settings."15-gdm-appearance" = {
      "/usr/share/gdm/dconf/95-appearance"."L+".argument = "${greeterDconf}";

      "/usr/share/icons/${cursorTheme}"."L+".argument =
        "${pkgs.bibata-cursors}/share/icons/${cursorTheme}";
    };
  };
}
