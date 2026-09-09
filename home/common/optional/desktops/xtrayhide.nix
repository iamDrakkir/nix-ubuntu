{ pkgs, ... }:

# X11 System Tray to StatusNotifierItem bridge.
#
# xtrayhide owns _NET_SYSTEM_TRAY_S0 on Xwayland, captures docked X11 tray
# icons, hides their windows and re-exports them over SNI so the bar can draw
# them. Without an owner of that selection, Wine apps that start minimised to
# the tray (Battle.net with AutoStartMinimized=true) have nowhere to dock: the
# launcher comes up mapped but never painted and the compositor tiles a solid
# black rectangle.
#
# Shared by the niri and umbriel modules — both are imported on terra, so this
# lives in its own file rather than being duplicated (the module system dedupes
# a repeated import, two conflicting definitions of the same unit would not).
{
  home.packages = [ pkgs.xtrayhide ];

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
      # Nothing orders this after Xwayland, so a cold session can fail several
      # starts before the display is up. With the default start limit systemd
      # eventually gives up and leaves the unit dead for the rest of the
      # session — which is exactly how Battle.net ends up as a black box.
      StartLimitIntervalSec = 0;
    };
  };
}
