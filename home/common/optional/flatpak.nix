{
  inputs,
  pkgs,
  ...
}:

{
  imports = [
    inputs.nix-flatpak.homeManagerModules.nix-flatpak
  ];

  # Make the Nix-provided flatpak package (and its D-Bus service files for the
  # flatpak portal) visible to the session bus.
  home.packages = [ pkgs.flatpak ];

  # Register the flatpak portal (org.freedesktop.portal.Flatpak) as a systemd
  # user service. On non-NixOS (Ubuntu) hosts this unit is not installed by the
  # distro, so `flatpak-spawn --sandbox` fails. Modern GNOME/GTK runtimes use
  # this via glycin to sandbox image loaders; without it apps like BambuStudio
  # abort with:
  #   Gtk:ERROR ensure_surface_for_gicon: Failed to load image-missing.svg
  #   (glycin-svg loader "exited early with status 1")
  systemd.user.services.flatpak-portal = {
    Unit = {
      Description = "flatpak portal";
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "dbus";
      BusName = "org.freedesktop.portal.Flatpak";
      ExecStart = "${pkgs.flatpak}/libexec/flatpak-portal";
    };
    Install.WantedBy = [ "default.target" ];
  };

  # D-Bus activation so the portal can start on demand as well.
  xdg.dataFile."dbus-1/services/org.freedesktop.portal.Flatpak.service".text = ''
    [D-BUS Service]
    Name=org.freedesktop.portal.Flatpak
    Exec=${pkgs.flatpak}/libexec/flatpak-portal
    SystemdService=flatpak-portal.service
  '';

  services.flatpak = {
    enable = true;
    packages = [
      "com.vysp3r.ProtonPlus"
      "net.davidotek.pupgui2"
      "com.usebottles.bottles"
      "com.bambulab.BambuStudio"
    ];
  };
}
