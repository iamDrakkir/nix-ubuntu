{ ... }:

# Ordering fixes for Ubuntu's xdg-desktop-portal units.
#
# Ubuntu's xdg-desktop-portal-gtk.service has no ordering at all: no
# After=/PartOf=graphical-session.target and no Restart=. On a session restart
# it gets D-Bus activated while the old DISPLAY=:0 is dead and the new
# compositor is not up yet, dies with "cannot open display: :0", and then sits
# in `failed` so every later activation just times out.
#
# xdg-desktop-portal proxies *every* backend advertising Settings, so the dead
# gtk backend blocks it even though gnome is healthy: three sequential 25s D-Bus
# timeouts (Settings, Notification, Inhibit) blow past the 90s unit start
# timeout and xdg-desktop-portal.service fails outright. Meanwhile GTK4 queries
# org.freedesktop.portal.Settings synchronously at startup for the dark-mode
# preference, so every GTK app launched in that window — ghostty in particular —
# hangs for ~2 minutes before drawing a window.
#
# Nothing here is compositor-specific: the broken unit is the distro's and the
# failure is a session restart racing a GTK app, so it applies to every session
# on these hosts. It lives beside xtrayhide.nix rather than inside one desktop
# module for that reason — parking it in umbriel/ only ever worked because terra
# imports every desktop module, so the drop-in landed no matter what booted.
#
# Drop-ins rather than re-declared units (as umbriel/default.nix does for the
# units it owns) because both the unit and the binary belong to the distro;
# re-declaring would mean hardcoding /usr/libexec/xdg-desktop-portal-gtk.
#
# Deliberately no ConditionEnvironment=WAYLAND_DISPLAY, unlike the umbriel
# backend: a failed condition makes systemd report the unit as successfully
# "started" without the bus name ever appearing, which reintroduces the 25s
# timeout instead of fixing it.
{
  xdg.configFile = {
    "systemd/user/xdg-desktop-portal-gtk.service.d/ordering.conf".text = ''
      [Unit]
      After=graphical-session.target
      PartOf=graphical-session.target
      StartLimitIntervalSec=0

      [Service]
      Restart=on-failure
      RestartSec=1s
    '';

    # Recovers the portal itself if it still manages to fail its start job;
    # without this it stays failed for the rest of the session.
    "systemd/user/xdg-desktop-portal.service.d/ordering.conf".text = ''
      [Unit]
      After=graphical-session.target
      StartLimitIntervalSec=0

      [Service]
      Restart=on-failure
      RestartSec=1s
    '';
  };
}
