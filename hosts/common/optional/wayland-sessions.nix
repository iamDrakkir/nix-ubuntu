{ pkgs, ... }:

# Wayland session entries for the display manager (GDM).
#
# These used to be written by home-manager into
# ~/.local/share/wayland-sessions/ and then copied to the system directory by
# hand via the `install-wayland-sessions` script — GDM only reads
# /usr/share/wayland-sessions/ (and won't follow symlinks into the Nix store),
# so the manual step was unavoidable at the home level.
#
# system-manager runs as root, so install them here instead: the service below
# copies real files into place on every rebuild and boot.
#
# The Exec launchers resolve the compositor through $HOME at runtime rather than
# a baked-in path, so the same session entry works for any user on the host.
let
  launcher =
    name: binary:
    pkgs.writeShellScript "${name}-session-launch" ''
      exec "$HOME/.nix-profile/bin/${binary}"
    '';

  sessions = {
    hyprland = pkgs.writeText "hyprland.desktop" ''
      [Desktop Entry]
      Name=Hyprland
      Comment=A dynamic tiling Wayland compositor
      Exec=${launcher "hyprland" "start-hyprland"}
      Type=Application
      DesktopNames=Hyprland
    '';

    niri = pkgs.writeText "niri.desktop" ''
      [Desktop Entry]
      Name=Niri
      Comment=A scrollable-tiling Wayland compositor
      Exec=${launcher "niri" "niri-session"}
      Type=Application
      DesktopNames=Niri
    '';
  };
in

{
  systemd.services.wayland-sessions-install = {
    description = "Install Wayland session entries into /usr/share/wayland-sessions";

    script = ''
      install -d -m 0755 /usr/share/wayland-sessions

      ${builtins.concatStringsSep "\n" (
        pkgs.lib.mapAttrsToList (name: file: ''
          install -m 0644 ${file} /usr/share/wayland-sessions/${name}.desktop
          echo "✓ installed ${name}.desktop"
        '') sessions
      )}
    '';

    serviceConfig = {
      RemainAfterExit = true;
      Type = "oneshot";
    };

    wantedBy = [ "system-manager.target" ];
  };
}
