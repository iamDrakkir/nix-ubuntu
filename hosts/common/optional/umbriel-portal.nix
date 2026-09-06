{
  inputs,
  system,
  ...
}:

# xdg-desktop-portal (1.18.x) discovers backends only in the compile-time
# /usr/share/xdg-desktop-portal/portals; XDG_DATA_DIRS is never consulted, so a
# backend installed into the user's Nix profile is invisible and the frontend
# silently omits ScreenCast and Screenshot.
#
# XDG_DESKTOP_PORTAL_DIR would override that path, but it *replaces* the
# directory rather than adding to it and would hide the distro's gtk and gnome
# backends. Link the file into place instead, as corectrl.nix does for D-Bus and
# polkit files that must live under /usr/share.
let
  portal = inputs.umbriel.inputs.xdg-desktop-portal-umbriel.packages.${system}.default;
in

{
  systemd.tmpfiles.settings."10-umbriel-portal"."/usr/share/xdg-desktop-portal/portals/umbriel.portal"."L+".argument =
    "${portal}/share/xdg-desktop-portal/portals/umbriel.portal";
}
